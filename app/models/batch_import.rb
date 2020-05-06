# frozen_string_literal: true

class BatchImport < ApplicationRecord
  PENDING = 'pending'
  IN_PROGRESS = 'in_progress'
  COMPLETED_SUCCESSFULLY = 'completed_successfully'
  COMPLETE_WITH_FAILURES = 'complete_with_failures'
  CANCELLED = 'cancelled'

  STATUSES = [PENDING, IN_PROGRESS, COMPLETED_SUCCESSFULLY, COMPLETE_WITH_FAILURES, CANCELLED].freeze

  enum priority: { low: 0, medium: 1, high: 2 }
  serialize :setup_errors, Array

  before_destroy :ensure_imports_are_complete!, prepend: true
  after_destroy :delete_associated_file

  has_many :digital_object_imports, dependent: :destroy
  belongs_to :user

  validates :priority, presence: true

  def delete_associated_file
    Hyacinth::Config.batch_import_storage.delete(file_location) if file_location.present?
  end

  def status
    return CANCELLED if cancelled

    total_imports = import_status_count.values.sum
    if import_count('in_progress').positive?
      IN_PROGRESS
    elsif import_count('pending').positive? || total_imports.zero?
      PENDING
    elsif import_count('success') == total_imports
      COMPLETED_SUCCESSFULLY
    else
      COMPLETE_WITH_FAILURES
    end
  end

  # This method queries for the count of each status once and caches it. For subsequent requests the same
  # count will be used, it will not be recalculated.
  def import_status_count
    @import_status_count ||= digital_object_imports.group(:status).count
  end

  def import_count(status)
    import_status_count[status] || 0
  end

  # Moves active storage blob into permanent storage, saves location and original filename to batch import.
  def add_blob(blob)
    storage = Hyacinth::Config.batch_import_storage
    location = storage.generate_new_location_uri(SecureRandom.uuid)

    self.original_filename = blob.filename.to_s
    self.file_location = location

    storage.with_writable(location) do |output_file|
      blob.download { |chunk| output_file << chunk }
    end
  end

  # Returns csv string with successful rows removed. Keeps the original order of the rows.
  def csv_without_successful_imports
    raise 'Cannot generate csv without successful rows without file_location' unless file_location
    # Using set for faster lookup
    unsuccessful_indices = digital_object_imports.where.not(status: :success).pluck(:index).to_set

    storage = Hyacinth::Config.batch_import_storage

    new_csv = ''

    storage.with_readable(file_location) do |io|
      csv = CSV.new(io, headers: :first_row, return_headers: true)
      csv.each_with_index do |row, index|
        new_csv += CSV.generate_line(row) if row.header_row? || unsuccessful_indices.include?(index + 1)
      end
    end

    new_csv
  end

  def self.csv_file_to_hierarchical_json_hash(csv_file)
    JsonCsv.csv_file_to_hierarchical_json_hash(csv_file.path) do |json_hash_for_row, csv_row_number|
      # Convert csv-formatted, header-derived json to the expected attribute format
      BatchImport.import_json_to_digital_object_attribute_format!(json_hash_for_row)
      yield json_hash_for_row, csv_row_number
    end
  end

  # Reads the csv data from the given blob and performs "pre-validation" on the CSV data.
  # "Pre-validation" is a non-comprehensive check that's meant to quickly catch common errors
  # without doing more computationally expensive operations like creating objects or doing extensive
  # database queries.  This method is primarily used for validating a CSV before it's split up and
  # turned into DigitalObjectImports, which have more extensive checks done as they're processed.
  #
  # @return Array(Boolean, String[])
  #   Sample return value for failed validation:
  #   [false, ['Something went wrong!', 'Something else went wrong!']]
  #   Sample return value for successful validation:
  #   [true, []]
  def self.pre_validate_blob(blob)
    pre_validation_errors = []
    blob.open do |file|
      # TODO: Make sure there aren't any duplicate headers
      csv_file_to_hierarchical_json_hash(file) do |json_hash_for_row, _csv_row_number|
        # TODO: Make sure that only valid fields are present in the dynamic field data properties
        # TODO: Make sure that all new object rows have a digital_object_type
        # TODO: Make sure that all referenced projects exist
        # TODO: Make sure that all new asset rows minimally have a master
        # TODO: Make sure that the same UID doesn't appear in more than one row
      end
    end

    [pre_validation_errors.blank?, pre_validation_errors]
  end

  # Converts a CSV-header-derived JSON-like hash structure to the expected digital object
  # attribute format, moving all non-underscore-prefixed top level key-value pairs under
  # descriptive_metadata and removing the underscore prefix from all top level keys.
  # Note: This method modifies the passed-in object!
  def self.import_json_to_digital_object_attribute_format!(import_json)
    # Add descriptive_metadata hash
    descriptive_metadata = {}

    # Move all non-underscore-prefixed keys under descriptive_metadata
    import_json.delete_if do |key|
      next false if key.start_with?('_')
      descriptive_metadata[key] = import_json[key]
      true
    end

    # Assign descriptive_metadata to 'descriptive_metadata' key in import_json
    import_json['descriptive_metadata'] = descriptive_metadata

    # Remove leading underscore from all remaining underscore-prefixed keys
    import_json.transform_keys! { |key| key.start_with?('_') ? key[1..-1] : key }

    # Return modified hash
    import_json
  end

  private

    # Callback to check that a batch import can be deleted. A batch import
    # can only be deleted if it's cancelled and no digital object imports
    # are in progress or if no digital object imports are 'in_progress' or 'pending'
    def ensure_imports_are_complete!
      imports_pending = import_count('pending').positive?
      imports_in_progress = import_count('in_progress').positive?

      if cancelled && imports_in_progress
        errors[:base] << 'Cannot destroy cancelled batch import while imports are in_progress'
        throw :abort
      elsif !cancelled && (imports_in_progress || imports_pending)
        errors[:base] << 'Cannot destroy batch import while imports are in_progress or pending'
        throw :abort
      end
    end
end
