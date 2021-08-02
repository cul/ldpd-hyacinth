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
            next unless resource.preservable && resource.content_exists?
            ensure_datastream(fedora_obj, resource_name, datastream_props_for(resource_name, resource))
            datastream = fedora_obj.datastreams[resource_name]
            content_digest = md5_digest(resource)
            # Only update content if it has changed
            next if datastream.checksum == content_digest
            resource.with_readable do |blob|
              datastream.content = blob.read
              datastream.checksum = content_digest
            end
          end
        end

        def datastream_props_for(resource_name, resource)
          {
            versionable: resource.versionable,
            mimeType: resource.media_type,
            controlGroup: 'M',
            dsLabel: resource.original_file_path || "#{resource_name}.txt",
            checksumType: 'MD5'
          }
        end

        def md5_digest(resource)
          md5 = Digest::MD5.new
          resource.with_readable do |blob|
            blob.each(nil, 1024**2) { |chunk| md5.update(chunk) }
          end
          md5.hexdigest
        end
      end
    end
  end
end
