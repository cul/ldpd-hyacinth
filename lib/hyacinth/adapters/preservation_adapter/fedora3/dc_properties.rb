module Hyacinth
  module Adapters
    module PreservationAdapter
      class Fedora3::DCProperties
        XML_PREFIX = '<oai_dc:dc xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"'\
                     ' xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd">'.freeze
        XML_SUFFIX = '</oai_dc:dc>'.freeze

        include Fedora3::PidHelpers
        include Fedora3::TitleHelpers
        include Fedora3::DatastreamMethods

        def self.from(hyacinth_obj)
          new(hyacinth_obj)
        end

        def initialize(hyacinth_obj)
          @hyacinth_obj = hyacinth_obj
        end

        def to(fedora_obj)
          proposed_dc_properties = proposed_dc_properties(@hyacinth_obj)
          current_dc_properties = parse_dc_xml(fedora_obj)
          fedora_obj.datastreams['DC'].content = to_dc_xml(proposed_dc_properties) unless current_dc_properties.eql?(proposed_dc_properties)
        end

        def proposed_dc_properties(hyacinth_obj = @hyacinth_obj)
          properties = {}
          # set the title
          properties[:title] = [get_title(hyacinth_obj.dynamic_field_data)]
          # set the identifiers
          properties[:identifier] = hyacinth_obj.identifiers&.to_a || []
          # add the pid as an identifier
          properties[:identifier].concat Array.wrap(digital_object_fedora_uris(hyacinth_obj))
          if is_asset_type?(hyacinth_obj)
            # set the type
            properties[:type] = [hyacinth_obj.asset_type].compact
            # set the source
            filename = hyacinth_obj.resources['master'].original_filename || hyacinth_obj.resources['master'].location
            properties[:source] = [filename].compact
            # set the format (MIME)
            properties[:format] = [BestType.mime_type.for_file_name(filename)].compact
          end
          normalized_properties(properties)
        end

        def parse_dc_xml(fedora_obj)
          properties = Hash.new { |hash, key| hash[key] = [] }
          ng_xml = Nokogiri::XML(fedora_obj.datastreams['DC'].content)
          ng_xml.remove_namespaces!
          dc = ng_xml.at_css("dc")
          dc.elements.each { |ele| properties[ele.name.to_sym] << ele.text.strip }
          normalized_properties(properties)
        end

        def normalized_properties(properties = {})
          properties.map do |k, v|
            v = Array.wrap(v)
            v.uniq!
            v.sort!
            [k, v]
          end.to_h
          properties.delete_if { |_k, v| !v.detect(&:present?) }
          properties
        end

        def to_dc_xml(properties = {})
          xml = XML_PREFIX.dup
          properties.each do |property, values|
            Array.wrap(values).compact.each do |value|
              xml << "<dc:#{property}>#{value}</dc:#{property}>"
            end
          end
          xml << XML_SUFFIX
        end

        private
          def is_asset_type?(hyacinth_obj)
            hyacinth_obj.respond_to? :asset_type
          end
      end
    end
  end
end
