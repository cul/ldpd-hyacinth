# frozen_string_literal: true

module Hyacinth
  module Adapters
    module PreservationAdapter
      class Fedora3::TextResourceProperties
        include Fedora3::DatastreamMethods

        def self.from(hyacinth_obj)
          new(hyacinth_obj)
        end

        def initialize(hyacinth_obj)
          @hyacinth_obj = hyacinth_obj
        end

        def to(fedora_obj)
          return unless @hyacinth_obj.is_a? ::DigitalObject::Asset
          ::DigitalObject::Asset::TEXT_RESOURCE_NAMES.each do |resource_name|
            next unless @hyacinth_obj.send :"has_#{resource_name}_resource?"
            resource = @hyacinth_obj.send :"#{resource_name}_resource"
            resource_config = @hyacinth_obj.class.resource_attributes.fetch(resource_name.to_sym, {})
            next unless resource_config[:preservable] && resource.content_exists?
            ensure_datastream(fedora_obj, resource_name, datastream_props_for(resource_name, resource_config, resource))
            datastream = fedora_obj.datastreams[resource_name]
            # Only update content if it has changed
            next if "sha256:#{datastream.checksum}" == resource.checksum
            resource.with_readable do |blob|
              datastream.content = blob.read
              datastream.checksum = resource.checksum.sub("sha256:", '')
            end
          end
        end

        def datastream_props_for(resource_name, resource_config, resource)
          {
            versionable: resource_config.fetch(:versionable, false),
            mimeType: resource.media_type,
            controlGroup: 'M',
            dsLabel: resource.original_file_path || "#{resource_name}.txt",
            checksumType: 'SHA-256'
          }
        end
      end
    end
  end
end
