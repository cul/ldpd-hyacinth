# frozen_string_literal: true

module Hyacinth
  module Adapters
    module PreservationAdapter
      class Fedora3::StructProperties
        DSID = 'structMetadata'.freeze
        XML_PREFIX = '<mets:structMap xmlns:mets="http://www.loc.gov/METS/" LABEL="Sequence" TYPE="logical">'.freeze
        XML_SUFFIX = '</mets:structMap>'.freeze

        include Fedora3::TitleHelpers
        include Fedora3::DatastreamMethods

        def self.from(hyacinth_obj)
          new(hyacinth_obj)
        end

        def initialize(hyacinth_obj)
          @hyacinth_obj = hyacinth_obj
        end

        def to(fedora_obj)
          return unless @hyacinth_obj.structured_children.detect(&:present?)
          proposed_list = structured_children(@hyacinth_obj)
          current_list = parse_struct_xml(fedora_obj)
          return if current_list.eql? proposed_list
          ensure_datastream(fedora_obj, DSID, versionable: false, mimeType: 'text/xml')
          fedora_obj.datastreams[DSID].content = to_struct_xml(proposed_list)
        end

        def structured_children(hyacinth_obj = @hyacinth_obj)
          list = []
          hyacinth_obj.structured_children['structure'].each_with_index do |uid, ix|
            child = ::DigitalObject::Base.find(uid)
            list << { uid: uid, order: (ix + 1).to_s, label: get_title(child.dynamic_field_data) }
          end
          list
        end

        def parse_struct_xml(fedora_obj)
          return [] if fedora_obj.datastreams[DSID].new?
          ng_xml = Nokogiri::XML(fedora_obj.datastreams[DSID].content)
          ng_xml.remove_namespaces!
          struct_map = ng_xml.at_css("structMap")
          list = struct_map.elements.map { |ele| { uid: ele['CONTENTIDS'], label: ele['LABEL'], order: ele['ORDER'] } }
          list
        end

        def to_struct_xml(proposed_list)
          xml = "#{XML_PREFIX}\n"
          proposed_list.each do |child|
            xml << "<mets:div LABEL=\"#{child[:label]}\" ORDER=\"#{child[:order]}\" CONTENTIDS=\"#{child[:uid]}\"/>\n"
          end
          xml << XML_SUFFIX
        end
      end
    end
  end
end
