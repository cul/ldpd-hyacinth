# frozen_string_literal: true

module Hyacinth
  module DynamicFieldsLoader
    # Loads fields with a serialized representation of fields. If a field is already present that field is updated with
    # the new attributes given. If there's a problem loading a field an error will be raised and all changes will be
    # rolled back. Optionally vocabularies can also be created if a dynamic field depends on it.
    #
    # @param field_definitions [Hash] serialized hash containing field definitions
    #   Format should look like the following example. Each hash should contain all the fields required by that model.
    #      {
    #         dynamic_field_categories: [
    #           {
    #             display_label: 'Descriptive Metadata',
    #             metadata_form: 'descriptive',
    #             dynamic_field_groups: [
    #               {
    #                 string_key: 'name',
    #                 display_label: 'Name',
    #                 dynamic_field_groups: {
    #                   string_key: 'role',
    #                   dynamic_fields: [
    #                     { string_key: 'term', field_type: 'controlled_term' }
    #                   ]
    #                 }
    #               }
    #             ]
    #           }
    #         ]
    #       }
    # @param [opts] options to use when generating fields
    # @option opts [Boolean] :load_vocabularies option to load any vocabularies fields are dependent on
    def self.load_fields!(field_definitions, opts = {})
      # If all this fields are not loaded successfully we need to rollback any changes.
      ActiveRecord::Base.transaction do
        # Load Item and Asset Rights Fields
        field_definitions[:dynamic_field_categories].each do |category_config|
          display_label = category_config.delete(:display_label)
          child_dynamic_field_groups = category_config.delete(:dynamic_field_groups)

          category = DynamicFieldCategory.find_or_create_by!(display_label: display_label) do |c|
            c.assign_attributes(category_config)
          end

          create_dynamic_field_groups!(category, child_dynamic_field_groups, opts)
        end
      end
    end

    # Loads rights dynamic field groups and dynamic fields defined in config/rights_fields.yml. Does
    # not redefine fields if they are already defined. Optionally loads vocabularies as well.
    #
    # @param [opts] options to use when generating fields
    # @option opts [Boolean] :load_vocabularies option to load any vocabularies fields are dependent on
    def self.load_rights_fields!(opts = {})
      config_file = Rails.root.join('config', 'rights_fields.yml')

      raise 'Missing config/rights_fields.yml' unless File.exist?(config_file)

      config = YAML.load_file(config_file).with_indifferent_access
      rights_fields = config[:rights_fields]

      raise 'Missing configuration for item rights fields' unless rights_fields[:item]
      raise 'Missing configuration for asset rights fields' unless rights_fields[:asset]

      dynamic_field_categories = [:item, :asset].map do |type|
        {
          display_label: "#{type.to_s.titleize} Rights",
          metadata_form: "#{type}_rights",
          dynamic_field_groups: rights_fields[type]
        }
      end

      load_fields!({ dynamic_field_categories: dynamic_field_categories }, opts)
    end

    def self.create_dynamic_field_groups!(parent, dynamic_field_groups_config, opts)
      dynamic_field_groups_config.each do |group_config|
        # create group if it doesn't exist already
        child_dynamic_fields = group_config.delete(:dynamic_fields)
        child_dynamic_field_groups = group_config.delete(:dynamic_field_groups)
        string_key = group_config.delete(:string_key)

        group = DynamicFieldGroup.find_or_create_by!(string_key: string_key, parent: parent) do |g|
          g.assign_attributes(group_config)
        end

        # iterate and create all the children attached to this group
        create_dynamic_fields!(group, child_dynamic_fields, opts) if child_dynamic_fields.present?
        create_dynamic_field_groups!(group, child_dynamic_field_groups, opts) if child_dynamic_field_groups.present?
      end
    end

    def self.create_dynamic_fields!(group, dynamic_fields_config, opts)
      # Throw error if vocabulary is not present
      dynamic_fields_config.each do |field_config|
        string_key = field_config.delete(:string_key)
        field = DynamicField.find_or_create_by!(string_key: string_key, dynamic_field_group: group) do |f|
          f.assign_attributes(field_config)
        end

        # Load vocabulary if flag is true and it's a controlled term field.
        next unless opts[:load_vocabularies] && field.field_type == DynamicField::Type::CONTROLLED_TERM

        Vocabulary.find_or_create_by!(string_key: field.controlled_vocabulary) do |vocab|
          vocab.label = field.controlled_vocabulary.tr('_', ' ').titleize
        end
      end
    end
  end
end
