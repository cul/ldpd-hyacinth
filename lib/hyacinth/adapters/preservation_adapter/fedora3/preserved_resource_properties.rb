# frozen_string_literal: true

module Hyacinth
  module Adapters
    module PreservationAdapter
      class Fedora3::PreservedResourceProperties
        include Fedora3::DatastreamMethods
        include Fedora3::PropertyContextInitializers

        def to(fedora_obj)
          @hyacinth_obj.resource_attribute_names.each do |resource_name|
            resource_name = resource_name.to_s
            resource = preservable_resource(resource_name)
            preservable_config = preservable_resource_config(resource_name)
            next unless resource && preservable_config.present?
            dsid = adapter.resource_dsid_overrides.fetch(resource_name, resource_name)
            ensure_datastream(fedora_obj, dsid, datastream_props_for(resource_name, preservable_config, resource))
            datastream = fedora_obj.datastreams[dsid]
            validate_configuration_against_control_group(resource_name, preservable_config, datastream)
            # Only update content if it has changed
            next if "sha256:#{datastream.checksum}" == resource.checksum
            preserve_content(resource, preservable_config, datastream) if datastream.controlGroup == 'M'
            preserve_location(resource, preservable_config, datastream) if datastream.controlGroup == 'E'
          end
        end

        def preservable_resource(resource_name)
          return nil unless @hyacinth_obj.send :"has_#{resource_name}_resource?"
          resource = @hyacinth_obj.send :"#{resource_name}_resource"
          resource.content_exists? ? resource : nil
        end

        def preservable_resource_config(resource_name)
          resource_config = @hyacinth_obj.class.resource_attributes.fetch(resource_name.to_sym, {})
          resource_config.fetch(:preservable, {})
        end

        def validate_configuration_against_control_group(resource_name, preservable_config, datastream)
          valid_config = (preservable_config[:as] == :copy && datastream.controlGroup == 'M')
          valid_config ||= (preservable_config[:as] == :reference && datastream.controlGroup == 'E')
          raise "Cannot to preserve #{resource_name} as #{preservable_config[:as]}: existing datastream control group #{datastream.controlGroup}" unless valid_config
        end

        def preserve_content(resource, preservable_config, datastream)
          resource.with_readable do |blob|
            datastream.content = blob.read
            datastream.checksum = resource.checksum.sub("sha256:", '') if preservable_config.fetch(:verify_checksum, false)
          end
        end

        def preserve_location(resource, _preservable_config, datastream)
          storage_adapter = Hyacinth::Config.resource_storage.storage_adapter_for_location(resource.location)
          raise "Cannot preserve non-disk stored resources by reference (#{Hyacinth::Config.resource_storage.class.name})" unless storage_adapter.respond_to? :location_uri_to_file_path
          datastream.dsLocation = "file:" + storage_adapter.location_uri_to_file_path(resource.location)
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
