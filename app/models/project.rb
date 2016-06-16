class Project < ActiveRecord::Base
  has_many :enabled_dynamic_fields, dependent: :destroy
  accepts_nested_attributes_for :enabled_dynamic_fields, allow_destroy: true

  has_many :users, through: :project_permissions
  has_many :project_permissions, dependent: :destroy
  accepts_nested_attributes_for :project_permissions, allow_destroy: true, reject_if: proc { |attributes| attributes['id'].blank? && attributes['user_id'].blank? }

  has_many :publish_targets, through: :enabled_publish_targets
  has_many :enabled_publish_targets, dependent: :destroy
  accepts_nested_attributes_for :enabled_publish_targets, allow_destroy: true

  belongs_to :pid_generator

  validates :display_label, :string_key, presence: true
  validate :validate_custom_asset_directory

  before_create :create_associated_fedora_object!
  after_save :update_fedora_object!, :ensure_that_title_fields_are_enabled_and_required
  after_destroy :mark_fedora_object_as_deleted!

  delegate :next_pid, to: :pid_generator

  # Returns the associated Fedora Object
  def fedora_object
    if pid.present?
      return @fedora_object ||= ActiveFedora::Base.find(pid)
    else
      return nil
    end
  end

  def create_associated_fedora_object!
    pid = next_pid
    concept = Concept.new(pid: pid)
    @fedora_object = concept
    self.pid = @fedora_object.pid
  end

  def update_fedora_object!
    fedora_object.datastreams["DC"].dc_identifier = [pid]
    fedora_object.datastreams["DC"].dc_type = 'Project'
    fedora_object.datastreams["DC"].dc_title = display_label
    fedora_object.label = display_label
    fedora_object.save(update_index: false)
  end

  def mark_fedora_object_as_deleted!
    fedora_object.state = 'D'
  end

  # Returns enabled dynamic fields (with eager-loaded nested dynamic_field data because we use that frequently)
  def enabled_dynamic_fields_for_type(digital_object_type)
    enabled_dynamic_fields.includes(:dynamic_field).where(digital_object_type: digital_object_type).to_a
  end

  # Get dynamic_field_ids for enabled dynamic fields, irregardless of object type, no duplicates
  def enabled_dynamic_field_ids
    enabled_dynamic_fields.select(:dynamic_field_id).distinct.pluck(:dynamic_field_id).to_a
  end

  def asset_directory
    if full_path_to_custom_asset_directory.present?
      full_path_to_custom_asset_directory
    else
      File.join(HYACINTH['default_asset_home'], string_key)
    end
  end

  def ensure_that_title_fields_are_enabled_and_required
    changes_require_save = false

    # For all DigitalObjectTypes that contain ANY enabled dynamic fields, ensure that the title fields are always enabled (and that title_non_sort_portion is always required)

    DigitalObjectType.all.find_each do |digital_object_type|
      # If enabled_dynamic_fields_for_type includes the title fields, make sure that they're set as *required*
      # If not, enable them and set them as required
      enabled_dynamic_fields_for_type =
        enabled_dynamic_fields.select { |enabled_dynamic_field| enabled_dynamic_field.digital_object_type == digital_object_type }
      ensure_enabled = {
        'title_non_sort_portion' => { 'required' => false },
        'title_sort_portion' => { 'required' => true }
      }
      must_be_enabled = []
      found_enabled = []

      # Iterate over existing enabled_dynamic_field
      enabled_dynamic_fields_for_type.each do |enabled_df|
        must_be_enabled = ensure_enabled.keys if must_be_enabled.empty?
        next unless must_be_enabled.include?(enabled_df.dynamic_field.string_key)
        found_enabled << enabled_df.dynamic_field.string_key
        if ensure_enabled[enabled_df.dynamic_field.string_key]['required'] && !enabled_df.required
          enabled_df.required = true
          changes_require_save = true
        end
      end

      (must_be_enabled - found_enabled).each do |string_key|
        enabled_dynamic_fields << EnabledDynamicField.new(
          dynamic_field: DynamicField.find_by(string_key: string_key),
          digital_object_type: digital_object_type,
          required: ensure_enabled[string_key]['required']
        )
        changes_require_save = true
      end
    end

    save if changes_require_save
  end

  def enabled_digital_object_types
    EnabledDynamicField.includes(:digital_object_type).select(:digital_object_type_id).distinct.where(project: self).map(&:digital_object_type).sort_by(&:sort_order)
  end

  def as_json(_options = {})
    {
      pid: pid,
      uri: uri.present? ? uri : nil,
      display_label: display_label,
      string_key: string_key
    }
  end

  private

    def validate_custom_asset_directory
      return unless full_path_to_custom_asset_directory.present?

      all_permissions = File.exist?(asset_directory) &&
                        File.readable?(asset_directory) &&
                        File.writable?(asset_directory)
      errors.add(:full_path_to_custom_asset_directory, 'could not be written to.  Ensure that the path exists and has the correct read/write permissions: "' + full_path_to_custom_asset_directory + '"') unless all_permissions
    end
end
