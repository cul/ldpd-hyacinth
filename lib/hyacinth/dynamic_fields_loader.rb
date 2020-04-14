# frozen_string_literal: true

module Hyacinth
  module DynamicFieldsLoader
    def self.load_rights_fields!
      config_file = Rails.root.join('config', 'rights_fields.yml')

      raise 'Missing config/rights_fields.yml' unless File.exist?(config_file)

      config = YAML.load_file(config_file).with_indifferent_access
      rights_fields = config[:rights_fields]

      raise 'Missing configuration for item rights fields' unless rights_fields[:item]
      raise 'Missing configuration for asset rights fields' unless rights_fields[:asset]

      # If all this fields are not loaded successfully we need to rollback any changes.
      ActiveRecord::Base.transaction do
        # Load Item and Asset Rights Fields
        [:item, :asset].each do |form_type|
          category = DynamicFieldCategory.find_or_create_by!(
            display_label: "#{form_type.to_s.titleize} Rights", metadata_form: "#{form_type}_rights"
          )
          create_dynamic_field_groups!(category, rights_fields[form_type])
        end
      end
    end

    def self.create_dynamic_field_groups!(parent, dynamic_field_groups_config)
      dynamic_field_groups_config.each do |group_config|
        # create group if it doesn't exist already
        child_dynamic_fields = group_config.delete(:dynamic_fields)
        child_dynamic_field_groups = group_config.delete(:dynamic_field_groups)
        string_key = group_config.delete(:string_key)

        group = DynamicFieldGroup.find_or_create_by!(string_key: string_key, parent: parent) do |g|
          g.assign_attributes(group_config)
        end

        # iterate and create all the children attached to this group
        create_dynamic_fields!(group, child_dynamic_fields) if child_dynamic_fields.present?
        create_dynamic_field_groups!(group, child_dynamic_field_groups) if child_dynamic_field_groups.present?
      end
    end

    def self.create_dynamic_fields!(group, dynamic_fields_config)
      # Throw error if vocabulary is not present
      dynamic_fields_config.each do |field_config|
        string_key = field_config.delete(:string_key)
        DynamicField.find_or_create_by!(string_key: string_key, dynamic_field_group: group) do |field|
          field.assign_attributes(field_config)
        end
      end
    end
  end
end
