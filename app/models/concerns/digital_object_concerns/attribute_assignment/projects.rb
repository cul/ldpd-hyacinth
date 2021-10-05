# frozen_string_literal: true

module DigitalObjectConcerns
  module AttributeAssignment
    module Projects
      extend ActiveSupport::Concern

      def assign_projects(digital_object_data)
        assign_primary_project(digital_object_data)
        assign_other_projects(digital_object_data)
      end

      def assign_primary_project(digital_object_data)
        primary_project_data = digital_object_data['primary_project']
        return unless primary_project_data
        dereferenced = primary_project_data.is_a?(Project)
        self.primary_project = dereferenced ? primary_project_data : dereference_project_string_key(primary_project_data['string_key'], true)
      end

      def assign_other_projects(digital_object_data)
        return unless digital_object_data.key?('other_projects')
        self.other_projects = Set.new(digital_object_data['other_projects'].map { |digital_object_data_project|
          if digital_object_data_project.is_a? Project
            digital_object_data_project
          else
            dereference_project_string_key(digital_object_data_project['string_key'], true)
          end
        })
      end

      def dereference_project_string_key(string_key, raise_error = false)
        # do not find_by! so that we control the exception implementation
        project_lookup = Project.find_by(string_key: string_key)
        raise Hyacinth::Exceptions::NotFound, "Could not find project for string key: #{string_key}" if project_lookup.nil? && raise_error
        project_lookup
      end
    end
  end
end
