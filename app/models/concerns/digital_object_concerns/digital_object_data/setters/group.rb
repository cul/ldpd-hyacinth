module DigitalObjectConcerns
  module DigitalObjectData::Setters
    module Group
      extend ActiveSupport::Concern

      def set_group(digital_object_data)
        return unless digital_object_data.key?('group')
        self.group = Group.find_by(string_key: digital_object_data['group']['string_key'])
      end
    end
  end
end
