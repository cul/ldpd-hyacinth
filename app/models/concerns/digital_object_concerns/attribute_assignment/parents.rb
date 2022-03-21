# frozen_string_literal: true

module DigitalObjectConcerns
  module AttributeAssignment
    module Parents
      extend ActiveSupport::Concern

      def assign_parents(digital_object_data)
        return unless digital_object_data.key?('parents')

        new_set_of_uids = Set.new
        new_set_of_identifiers = Set.new

        # Get uids and identifiers
        digital_object_data['parents'].each do |dod_parent|
          if dod_parent['uid'].present?
            new_set_of_uids << dod_parent['uid']
          elsif dod_parent['identifier'].present?
            new_set_of_identifiers << dod_parent['identifier']
          else
            raise Hyacinth::Exceptions::NotFound, "Could not find parent digital object using find criteria: #{dod_parent.inspect}"
          end
        end

        # Resolve any identifiers to uids and add them to new_set_of_uids
        new_set_of_identifiers.each do |identifier|
          uids = Hyacinth::Config.digital_object_search_adapter.identifier_to_uids(identifier, retry_with_delay: 5.seconds)

          if uids.blank?
            raise Hyacinth::Exceptions::NotFound,
                  "Could not find parent digital object using identifier: #{identifier}"
          elsif uids.length > 1
            raise Hyacinth::Exceptions::NotFound,
                  "Ambiguous parent linkage. Found more than one UID for identifier #{identifier}. UIDS: #{uids.join(', ')}"
          end
          new_set_of_uids << uids.first
        end

        current_parent_uids = self.currently_persisted_parent_uids

        # Add new UIDs that don't already exist in set of parents
        (new_set_of_uids - current_parent_uids).each do |uid|
          self.parents_to_add << DigitalObject.find_by_uid!(uid)
        end

        # Remove omitted UIDs that currently exist in set of parents
        (current_parent_uids - new_set_of_identifiers.to_a).each do |uid|
          self.parents_to_remove << DigitalObject.find_by_uid!(uid)
        end
      end
    end
  end
end
