module DigitalObjectConcerns
  module DigitalObjectData::Setters
    module General
      extend ActiveSupport::Concern
      # TODO: Test these methods via shared_example (https://stackoverflow.com/questions/16525222/how-to-test-a-concern-in-rails)

      def set_dynamic_field_data(digital_object_data, merge_dynamic_fields)
        return unless digital_object_data.key?('dynamic_field_data')
      end

      def set_optimistic_lock_token(digital_object_data)
        self.optimistic_lock_token = digital_object_data['optimistic_lock_token']
      end

      def set_state(digital_object_data)
        return unless digital_object_data.key?('state')
        self.state = digital_object_data['state']
      end

      def set_group(digital_object_data)
        return unless digital_object_data.key?('group')
        self.group = Group.find_by(string_key: digital_object_data['group']['string_key'])
      end

      def set_projects(digital_object_data)
        return unless digital_object_data.key?('projects')
        self.projects = digital_object_data['projects']
      end

      def set_parent_digital_objects(digital_object_data)
        digital_object_data['parent_digital_objects']
      end

      def set_resources(digital_object_data)
        digital_object_data['resources']
      end
    end
  end
end
