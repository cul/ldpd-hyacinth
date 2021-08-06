# frozen_string_literal: true

module Hyacinth
  module Adapters
    module PreservationAdapter
      class Fedora3::PreservedResourceProperties
        include Fedora3::DatastreamMethods
        include Fedora3::PropertyContextInitializers

        def to(fedora_obj)
          return unless @hyacinth_obj.is_a? ::DigitalObject::Asset
          @hyacinth_obj.resource_attribute_names.each do |resource_name|
            resource_name = resource_name.to_s
            next unless @hyacinth_obj.send :"has_#{resource_name}_resource?"
            resource = @hyacinth_obj.send :"#{resource_name}_resource"
            resource_config = @hyacinth_obj.class.resource_attributes.fetch(resource_name.to_sym, {})
            preservable_config = resource_config.fetch(:preservable, {})
            next unless preservable_config.present? && resource.content_exists?
            dsid = adapter.resource_dsid_overrides.fetch(resource_name, resource_name)
            ensure_datastream(fedora_obj, dsid, datastream_props_for(resource_name, preservable_config, resource))
            datastream = fedora_obj.datastreams[dsid]
            # Only update content if it has changed
            next if "sha256:#{datastream.checksum}" == resource.checksum
            preserve_content_or_location(resource, preservable_config, datastream)
          end
        end

        def preserve_content_or_location(resource, preservable_config, datastream)
          if preservable_config[:as] == :copy
            resource.with_readable do |blob|
              datastream.content = blob.read
              datastream.checksum = resource.checksum.sub("sha256:", '') if preservable_config.fetch(:verify_checksum, false)
            end
          else
            storage_adapter = Hyacinth::Config.resource_storage.storage_adapter_for_location(resource.location)
            raise "Cannot preserve non-disk stored resources by reference (#{Hyacinth::Config.resource_storage.class.name})" unless storage_adapter.respond_to? :location_uri_to_file_path
            datastream.dsLocation = "file:" + storage_adapter.location_uri_to_file_path(resource.location)
          end
        end

        def datastream_props_for(resource_name, preservable_config, resource)
          {
            versionable: preservable_config.fetch(:versionable, false),
            mimeType: resource.media_type,
            controlGroup: preservable_config[:as].eql?(:copy) ? 'M' : 'E',
            dsLabel: resource.original_file_path || "#{resource_name}.txt",
            checksumType: (preservable_config.fetch(:verify_checksum, false) ? 'SHA-256' : 'DISABLED')
          }
        end
      end
    end
  end
end
