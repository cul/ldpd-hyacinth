class MigrateHyacinthV1MetadataToV2 < ActiveRecord::Migration[6.0]
  # This migration is a data transformation that depends on DigitalObject after_commit callbacks
  # running in real time (rather than being delayed until the ENTIRE migration transaction is
  # complete), so we're turning off the migration transaction wrapper by running
  # disable_ddl_transaction! below.
  disable_ddl_transaction!

  def up
    parents_to_ordered_children = {}

    # Upgrade old metadata storage file to new format
    DigitalObject.in_batches(of: 200) do |digital_object_relation_group|
      digital_object_relation_group.pluck(:metadata_location_uri).each do |metadata_location_uri|
        old_data = JSON.parse(Hyacinth::Config.metadata_storage.read(metadata_location_uri))
        next if old_data['serialization_version'].to_s != '1'
        old_data.delete('serialization_version')

        uid = old_data.delete('uid')
        old_data.delete('structured_children').tap do |structured_children|
          next if structured_children.blank? || structured_children['structure'].blank?
          parents_to_ordered_children[uid] = structured_children['structure']
        end

        new_data = {
          'serialization_version' => 2, # we're upgrading to version 2
          'uid' => uid,
          'resources' => old_data.delete('resources')
        }

        # All remaining key-value pairs go under the 'metadata' key
        new_data['metadata'] = old_data

        # Persist changes to metadata storage
        Hyacinth::Config.metadata_storage.write(metadata_location_uri, JSON.generate(new_data))

        # Update the associated DigitalObject database record without instantiating it
        # (because instantiation would run into errors), via the update_all method:
        new_data['metadata'].tap do |metadata|
          DigitalObject.where(uid: new_data['uid']).update_all(
            type: "DigitalObject::#{metadata['digital_object_type'].classify}",
            created_at: metadata['created_at'] || DateTime.current,
            updated_at: metadata['updated_at'] || DateTime.current,
            first_published_at: metadata['first_published_at'],
            preserved_at: metadata['preserved_at'],
            first_preserved_at: metadata['first_preserved_at'],
            created_by_id: metadata['created_by'].nil? ? nil : User.find_by(uid: metadata['created_by']['uid']).id,
            updated_by_id: metadata['updated_by'].nil? ? nil : User.find_by(uid: metadata['updated_by']['uid']).id,
            state: metadata['state']
          )
        end
      end
    end

    # And then re-save all objects to clean up extraneous data in metadata storage file,
    # and when applicable link parents to children.
    DigitalObject.find_each(batch_size: 200) do |digital_object|
      print "Updating #{digital_object.uid} - metadata_location_uri: #{digital_object.metadata_location_uri} ..."
      if (ordered_child_uids = parents_to_ordered_children[digital_object.uid]).present?
        puts "For parent #{digital_object.uid}, adding children: #{ordered_child_uids.inspect}"
        DigitalObject.where(uid: ordered_child_uids).each do |child|
          digital_object.children_to_add << child
        end
      end
      digital_object.save!
    end
  end
end
