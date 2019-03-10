module DigitalObjectConcerns
  module DigitalObjectData::Setters
    module ParentUids
      extend ActiveSupport::Concern
      # TODO: Test these methods via shared_example (https://stackoverflow.com/questions/16525222/how-to-test-a-concern-in-rails)

      def set_parent_uids(digital_object_data)
        return unless digital_object_data.key?('parent_digital_objects')
        digital_object_data['parent_digital_objects']

        self.parent_digital_object_uids = digital_object_data['parent_digital_objects'].map do |dod_parent_digital_object|
          if dod_parent_digital_object['uid'].present?
            parent_uid = dod_parent_digital_object['uid']
            # Ensure that an object exists with the given uid
            unless DigitalObject::Base.exists?(parent_uid)
              raise Hyacinth::Exceptions::NotFound, "Could not find parent digital object with uid: #{parent_uid}"
            end
          elsif dod_parent_digital_object['identifier'].present?
            # Resolve identifier to uid
            uids = Hyacinth.config.search_adapter.identifier_to_uids(dod_parent_digital_object['identifier'])
            if uids.blank?
            elsif uids > 1
              raise Hyacinth::Exceptions::NotFound, "Ambiguous parent linkage. Found more than one UID for identifier #{dod_parent_digital_object['identifier']}. UIDS: #{uids.join(', ')}"
            else
              uids.first
            end
          else
            raise Hyacinth::Exceptions::NotFound, "Could not find parent digital object using find criteria: #{dod_parent_digital_object.inspect}"
          end
        end
      end

      def add_parent_uid(parent_uid)
        unless DigitalObject::Base.exists?(parent_uid)
          raise Hyacinth::Exceptions::NotFound, "Could not find parent digital object with uid: #{parent_uid}"
        end
        self.parent_uids << parent_uid
      end

      def remove_parent_uid(parent_uid)
        self.parent_uids.delete(parent_uid)
      end

    end
  end
end
