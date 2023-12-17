class Project < ApplicationRecord
  has_many :enabled_dynamic_fields, dependent: :destroy
  accepts_nested_attributes_for :enabled_dynamic_fields, allow_destroy: true

  has_many :users, through: :project_permissions
  has_many :project_permissions, dependent: :destroy
  accepts_nested_attributes_for :project_permissions, allow_destroy: true, reject_if: proc { |attributes| attributes['id'].blank? && attributes['user_id'].blank? }

  serialize :enabled_publish_target_pids, Array

  belongs_to :pid_generator

  validates :display_label, :string_key, presence: true
  validates :short_label, length: { maximum: 255 }, allow_blank: true
  validate :validate_custom_asset_directory

  before_create :create_associated_fedora_object!
  before_save :fill_in_short_label_if_blank!
  before_validation :set_valid_primary_publish_target_pid!
  after_save :update_fedora_object!, :ensure_that_title_fields_are_enabled_and_required
  after_destroy :mark_fedora_object_as_deleted!

  delegate :next_pid, to: :pid_generator

  # Returns the associated Fedora Object
  def fedora_object
    if pid.present?
      @fedora_object ||= Hyacinth::ActiveFedoraBaseWithCast.find(pid)
    else
      nil
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
    fedora_object.label = Hyacinth::Utils::StringUtils.escape_four_byte_utf8_characters_as_html_entities(display_label)
    fedora_object.save(update_index: false)
    fedora_object
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

  def fill_in_short_label_if_blank!
    self.short_label = display_label if short_label.blank?
  end

  def set_valid_primary_publish_target_pid!
    clear_blank_publish_target_values! # Eliminates first blank element submitted by multi-select in project edit form

    if enabled_publish_target_pids.blank?
      self.primary_publish_target_pid = nil
    elsif !enabled_publish_target_pids.include?(primary_publish_target_pid)
      self.primary_publish_target_pid = enabled_publish_target_pids.first
    end
    true
  end

  def clear_blank_publish_target_values!
    enabled_publish_target_pids.delete_if(&:blank?) unless enabled_publish_target_pids.nil?
  end

  def as_json(_options = {})
    {
      pid: pid,
      uri: uri.present? ? uri : nil,
      display_label: display_label,
      short_label: short_label,
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
