# frozen_string_literal: true

module Hyacinth
  module Adapters
    module PreservationAdapter
      module Fedora3::DatastreamMethods
        def ensure_datastream(fedora_object, dsid, props = {})
          default_props = { versionable: true }
          create_datastream(fedora_object, dsid, default_props.merge(props)) if fedora_object.datastreams[dsid].new?
        end

        def create_datastream(fedora_object, dsid, props = {})
          default_props = {
            controlGroup: 'M', dsLabel: dsid
          }
          ds = fedora_object.datastreams[dsid]
          props = default_props.merge(props)
          ds.content = props.delete(:blob) if props[:blob]
          default_props.merge(props).each do |prop, value|
            ds.send "#{prop}=".to_sym, value
          end
        end

        def ensure_json_datastream(fedora_object, dsid, props = {})
          return unless fedora_object.datastreams[dsid].new?

          default_props = { blob: JSON.generate({}) }
          create_json_datastream(fedora_object, dsid, default_props.merge(props))
        end

        def create_json_datastream(fedora_object, dsid, props = {})
          create_datastream(fedora_object, dsid, props.merge(mimeType: 'application/json'))
        end

        def create_xml_datastream(fedora_object, dsid, props = {})
          create_datastream(fedora_object, dsid, props.merge(mimeType: 'text/xml'))
        end
      end
    end
  end
end
