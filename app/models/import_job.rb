class ImportJob < ActiveRecord::Base
  after_destroy :delete_associated_file_if_exists

  # the name attribute will be the csv filename, and thus may not be unique
  validates :name, presence: true
  has_many :digital_object_imports, dependent: :destroy
  belongs_to :user, required: true

  def success?
    digital_object_imports.where(status: [DigitalObjectImport.statuses[:pending], DigitalObjectImport.statuses[:failure]]).empty?
  end

  def complete?
    count_pending_digital_object_imports.zero?
  end

  def status_string
    if count_pending_digital_object_imports.nonzero?
      'Incomplete'
    elsif count_failed_digital_object_imports.nonzero?
      'Complete with Failures'
    else
      'Successfully Completed'
    end
  end

  def pending_digital_object_imports
    digital_object_imports.where(status: DigitalObjectImport.statuses[:pending])
  end

  def successful_digital_object_imports
    digital_object_imports.where(status: DigitalObjectImport.statuses[:success])
  end

  def failed_digital_object_imports
    digital_object_imports.where(status: DigitalObjectImport.statuses[:failure])
  end

  def count_pending_digital_object_imports
    pending_digital_object_imports.count
  end

  def count_successful_digital_object_imports
    successful_digital_object_imports.count
  end

  def count_failed_digital_object_imports
    failed_digital_object_imports.count
  end

  def return_pending_digital_object_imports
    pending_digital_object_imports.to_a
  end

  def return_successful_digital_object_imports
    successful_digital_object_imports.to_a
  end

  def return_failed_digital_object_imports
    failed_digital_object_imports.to_a
  end

  def delete_associated_file_if_exists
    FileUtils.rm(path_to_csv_file) if path_to_csv_file.present? && File.exist?(path_to_csv_file)
  end

  def csv_row_numbers_for_all_non_successful_digital_object_imports
    digital_object_imports.where.not(status: DigitalObjectImport.statuses[:success]).pluck(:csv_row_number)
  end
end
