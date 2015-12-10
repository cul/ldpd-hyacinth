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

  def self.get_top_level_dynamic_field_groups
    return DynamicFieldGroup.where(parent_dynamic_field_group: nil)
  end

  def get_child_dynamic_fields_and_dynamic_field_groups
    child_dynamic_fields_and_dynamic_field_groups = []
    if self.child_dynamic_field_groups.present?
      child_dynamic_fields_and_dynamic_field_groups += self.child_dynamic_field_groups
    end

    if self.dynamic_fields.present?
      child_dynamic_fields_and_dynamic_field_groups += self.dynamic_fields
    end

    child_dynamic_fields_and_dynamic_field_groups = child_dynamic_fields_and_dynamic_field_groups.sort_by{|dynamic_field_or_dynamic_field_group|dynamic_field_or_dynamic_field_group.sort_order}
    return child_dynamic_fields_and_dynamic_field_groups
  end

  def is_top_level?
    return self.parent_dynamic_field_group.blank?
  end

  def as_json(options={})

    hash_to_return = {
      type: self.class.name,
      string_key: self.string_key,
      display_label: self.display_label,
      sort_order: self.sort_order,
      is_repeatable: self.is_repeatable,
      child_dynamic_fields_and_dynamic_field_groups: self.get_child_dynamic_fields_and_dynamic_field_groups
    }

    return hash_to_return
  end

  private

  def validate_dynamic_field_group_category
    # Top level dynamic_field_group should always have a dynamic_field_group_category
    if self.is_top_level?
      # This is top level
      if self.dynamic_field_group_category.blank?
        errors.add(:dynamic_field_group_category, "is required for top level Dynamic Field Groups.")
      end
    else
      # Non-top-level DynamicFieldGroup
      if self.dynamic_field_group_category.present?
        errors.add(:dynamic_field_group_category, "should not be present for non-top-level Dynamic Field Groups.")
      end
    end
  end

  # Validations
  def validate_json_fields
    if self.xml_translation.present? && ! Hyacinth::Utils::JsonUtils.valid_json?(self.xml_translation)
      errors.add(:xml_translation, "does not validate as JSON.  Value: " + self.xml_translation.to_s)
    end
  end

  # Before save cleanup

  def set_defaults_for_blank_fields

    # sort_order #
    if self.sort_order.blank?
      if self.parent_dynamic_field_group.blank?
        # If this DynamicFieldGroup is top level (i.e. has no parent_dynamic_field_group),
        # then its default sort_order should be based on all other top level DynamicFieldGroups
        temp = DynamicFieldGroup.where(parent_dynamic_field_group: nil).order(:sort_order => :desc).pluck(:sort_order)
        highest_sort_order = temp.blank? ? -1 : temp.first
        self.sort_order = highest_sort_order + 1
      else
        # If this DynamicFieldGroup IS NOT top level (i.e. it DOES have a parent_dynamic_field_group),
        # then its default sort_order should be determined by the existing order within its group
        temp = self.parent_dynamic_field_group.child_dynamic_field_groups.order("sort_order DESC").pluck(:sort_order)
        highest_parent_dynamic_field_group_sort_order_under_parent = temp.blank? ? -1 : temp.first

        temp = self.parent_dynamic_field_group.dynamic_fields.order(:sort_order => :desc).pluck(:sort_order)
        highest_dynamic_field_sort_order_under_parent = temp.blank? ? -1 : temp.first

        self.sort_order = [highest_parent_dynamic_field_group_sort_order_under_parent, highest_dynamic_field_sort_order_under_parent].max + 1
      end
    end

    # additional_data_json #
    self.xml_translation = [].to_json if self.xml_translation.blank?
  end

  def clean_up_json_fields
    self.xml_translation = JSON.pretty_generate(JSON(self.xml_translation), :indent => '    ')
  end

end
