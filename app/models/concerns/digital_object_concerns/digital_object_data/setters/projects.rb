module DigitalObjectConcerns
  module DigitalObjectData::Setters
    module Projects
      extend ActiveSupport::Concern

      def set_projects(digital_object_data)
        return unless digital_object_data.key?('projects')
        self.projects = Set.new(digital_object_data['projects'].each { |digital_object_data_project|
          Project.find_by(string_key: digital_object_data_project['string_key'])
        })
      end
    end
  end
end
