class DynamicFieldGroup < ActiveRecord::Base
  include DynamicFieldAndDynamicFieldGroup::SharedValidations

  has_many :dynamic_fields, class_name: 'DynamicField', foreign_key: 'parent_dynamic_field_group_id'

  belongs_to :dynamic_field_group_category

  belongs_to :parent_dynamic_field_group, class_name: 'DynamicFieldGroup'
  has_many :child_dynamic_field_groups, class_name: 'DynamicFieldGroup', foreign_key: 'parent_dynamic_field_group_id'

  belongs_to :created_by, class_name: 'User'
  belongs_to :updated_by, class_name: 'User'

  validate :validate_json_fields, :validate_dynamic_field_group_category

  before_save :set_defaults_for_blank_fields
  before_save :clean_up_json_fields

  # TODO: Delete this miethod if not used
  def self.top_level_dynamic_field_groups
    DynamicFieldGroup.where(parent_dynamic_field_group: nil)
  end

  def child_dynamic_fields_and_dynamic_field_groups
    child_dynamic_fields_and_dynamic_field_groups = []
    if child_dynamic_field_groups.present?
      child_dynamic_fields_and_dynamic_field_groups += child_dynamic_field_groups
    end

    if dynamic_fields.present?
      child_dynamic_fields_and_dynamic_field_groups += dynamic_fields
    end

    child_dynamic_fields_and_dynamic_field_groups.sort_by(&:sort_order)
  end

  def top_level?
    parent_dynamic_field_group.blank?
  end

  def as_json(_options = {})
    {
      type: self.class.name,
      string_key: string_key,
      display_label: display_label,
      sort_order: sort_order,
      is_repeatable: is_repeatable,
      child_dynamic_fields_and_dynamic_field_groups: child_dynamic_fields_and_dynamic_field_groups
    }
  end

  private

    def validate_dynamic_field_group_category
      # Top level dynamic_field_group should always have a dynamic_field_group_category
      top_level? ? validate_top_level_dynamic_field_group_category : validate_branch_field_group_category
    end

    def validate_top_level_dynamic_field_group_category
      # This is top level
      errors.add(:dynamic_field_group_category, "is required for top level Dynamic Field Groups.") if dynamic_field_group_category.blank?
    end

    def validate_branch_field_group_category
      # Non-top-level DynamicFieldGroup
      errors.add(:dynamic_field_group_category, "should not be present for non-top-level Dynamic Field Groups.") if dynamic_field_group_category.present?
    end

    # Validations
    def validate_json_fields
      return unless xml_translation.present?
      errors.add(:xml_translation, "does not validate as JSON.  Value: #{xml_translation}") unless Hyacinth::Utils::JsonUtils.valid_json?(xml_translation)
    end

    # Before save cleanup

    def set_defaults_for_blank_fields
      set_default_sort_order
      set_default_xml_translation
    end

    def set_default_sort_order
      return unless sort_order.blank?
      # sort_order #
      if parent_dynamic_field_group.blank?
        # If this DynamicFieldGroup is top level (i.e. has no parent_dynamic_field_group),
        # then its default sort_order should be based on all other top level DynamicFieldGroups
        temp = DynamicFieldGroup.where(parent_dynamic_field_group: nil).order(sort_order: :desc).pluck(:sort_order)
        highest_sort_order = temp.blank? ? -1 : temp.first
        self.sort_order = highest_sort_order + 1
      else
        # If this DynamicFieldGroup IS NOT top level (i.e. it DOES have a parent_dynamic_field_group),
        # then its default sort_order should be determined by the existing order within its group
        temp = parent_dynamic_field_group.child_dynamic_field_groups.order("sort_order DESC").pluck(:sort_order)
        highest_parent_dynamic_field_group_sort_order_under_parent = temp.blank? ? -1 : temp.first

        temp = parent_dynamic_field_group.dynamic_fields.order(sort_order: :desc).pluck(:sort_order)
        highest_dynamic_field_sort_order_under_parent = temp.blank? ? -1 : temp.first

        self.sort_order = [highest_parent_dynamic_field_group_sort_order_under_parent, highest_dynamic_field_sort_order_under_parent].max + 1
      end
    end

    def set_default_xml_translation
      # additional_data_json #
      self.xml_translation = [].to_json if xml_translation.blank?
    end

    def clean_up_json_fields
      self.xml_translation = JSON.pretty_generate(JSON(xml_translation), indent: '    ')
    end
end
