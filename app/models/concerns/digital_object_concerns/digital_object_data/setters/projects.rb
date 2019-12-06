# frozen_string_literal: true

module DigitalObjectConcerns
  module DigitalObjectData::Setters
    module Projects
      extend ActiveSupport::Concern

      def set_projects(digital_object_data)
        set_primary_project(digital_object_data)
        set_other_projects(digital_object_data)
      end

      def set_primary_project(digital_object_data)
        return unless digital_object_data.key?('primary_project')
        self.primary_project = Project.find_by(string_key: digital_object_data['primary_project']['string_key'])
      end

      def set_other_projects(digital_object_data)
        return unless digital_object_data.key?('other_projects')
        self.other_projects = Set.new(digital_object_data['other_projects'].map { |digital_object_data_project|
          Project.find_by(string_key: digital_object_data_project['string_key'])
        })
      end
    end
  end
end
