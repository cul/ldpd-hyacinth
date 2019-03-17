module DigitalObjectConcerns
  module DigitalObjectData::Setters
    module ParentUids
      extend ActiveSupport::Concern
      # TODO: Test these methods via shared_example (https://stackoverflow.com/questions/16525222/how-to-test-a-concern-in-rails)

      def set_parent_uids(digital_object_data)
        return unless digital_object_data.key?('parent_digital_objects')

        new_set_of_uids = Set.new
        new_set_of_identifiers = Set.new

        # Get uids and identifiers
        digital_object_data['parent_digital_objects'].each do |dod_parent_digital_object|
          if dod_parent_digital_object['uid'].present?
            new_set_of_uids << dod_parent_digital_object['uid']
          elsif dod_parent_digital_object['identifier'].present?
            new_set_of_identifiers << dod_parent_digital_object['identifier']
          else
            raise Hyacinth::Exceptions::NotFound, "Could not find parent digital object using find criteria: #{dod_parent_digital_object.inspect}"
          end
        end

        # Resolve any identifiers to uids and add them to new_set_of_uids
        new_set_of_identifiers.each do |identifier|
          uids = Hyacinth.config.search_adapter.identifier_to_uids(dod_parent_digital_object['identifier'], retry_with_delay: 5.seconds)
          if uids.blank?
            raise Hyacinth::Exceptions::NotFound, "Could not find parent digital object using identifier: #{dod_parent_digital_object['identifier']}"
          elsif uids > 1
            raise Hyacinth::Exceptions::NotFound, "Ambiguous parent linkage. Found more than one UID for identifier #{dod_parent_digital_object['identifier']}. UIDS: #{uids.join(', ')}"
          else
            new_set_of_uids << uids.first
          end
        end

        # Add new UIDs that don't already exist in set of parents
        (new_set_of_uids - self.parent_uids).each do |uid|
          add_parent_uid(uid, false)
        end

        # Remove omitted UIDs that currently exist in set of parents
        uids_to_remove.each do |uid|
          remove_parent_uid(uid)
        end
      end

      def add_parent_uid(uid, validate_existence_of_uid = true)
        @parent_uids_to_add << uid
      end

      def remove_parent_uid(uid)
        @parent_uids_to_remove << uid
      end

    end
  end
end
