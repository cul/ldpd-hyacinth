module Hyacinth
  module Adapters
    module PreservationAdapter
      class Fedora3::RelsExtProperties
        module URIS
          HAS_RDF_TYPE = "http://www.w3.org/1999/02/22-rdf-syntax-ns#type".freeze
          IS_PART_OF = "http://purl.org/dc/terms/isPartOf".freeze
          HAS_PROJECT = "http://dbpedia.org/ontology/project".freeze
          HAS_PUBLISHER = "http://purl.org/dc/terms/publisher".freeze
          HAS_DOI = "http://purl.org/ontology/bibo/doi".freeze
          HAS_MODEL = "info:fedora/fedora-system:def/model#hasModel".freeze
          # asset annotation properties
          IMAGE_WIDTH = "http://www.w3.org/2003/12/exif/ns#imageWidth".freeze
          IMAGE_LENGTH = "http://www.w3.org/2003/12/exif/ns#imageLength".freeze
          IMAGE_X_RES = "http://www.w3.org/2003/12/exif/ns#xResolution".freeze
          IMAGE_Y_RES = "http://www.w3.org/2003/12/exif/ns#yResolution".freeze
          IMAGE_RES_UNIT = "http://www.w3.org/2003/12/exif/ns#resolutionUnit".freeze
          IMAGE_ORIENTATION = "http://www.w3.org/2003/12/exif/ns#orientation".freeze
          FEATURED_REGION = "http://iiif.io/api/image/2#regionFeatured".freeze
          ORIGINAL_FILENAME = "http://www.loc.gov/premis/rdf/v1#hasOriginalName".freeze
        end

        include Fedora3::PidHelpers

        def self.from(hyacinth_obj)
          new(hyacinth_obj)
        end

        def initialize(hyacinth_obj)
          @hyacinth_obj = hyacinth_obj
        end

        def to(fedora_obj)
          # add child->parent URIs
          prospective_values = parent_uris_for(@hyacinth_obj)
          delta = delta_for(fedora_obj, URIS::IS_PART_OF, prospective_values)
          apply_delta(fedora_obj, URIS::IS_PART_OF, delta)
          # add constituent->project string keys
          prospective_values = project_string_keys_for(@hyacinth_obj)
          delta = delta_for(fedora_obj, URIS::HAS_PROJECT, prospective_values)
          apply_delta(fedora_obj, URIS::HAS_PROJECT, delta, isLiteral: true)
          # add object->publisher string keys
          prospective_values = publisher_string_keys_for(@hyacinth_obj)
          delta = delta_for(fedora_obj, URIS::HAS_PUBLISHER, prospective_values)
          apply_delta(fedora_obj, URIS::HAS_PUBLISHER, delta, isLiteral: true)
          # add DOI URIs
          prospective_values = dois_for(@hyacinth_obj)
          delta = delta_for(fedora_obj, URIS::HAS_DOI, prospective_values)
          apply_delta(fedora_obj, URIS::HAS_DOI, delta)
          # add content model URIs
          prospective_values = models_for(@hyacinth_obj)
          delta = delta_for(fedora_obj, URIS::HAS_MODEL, prospective_values)
          apply_delta(fedora_obj, URIS::HAS_MODEL, delta)
          # add rdf type URIs
          prospective_values = rdf_types_for(@hyacinth_obj)
          delta = delta_for(fedora_obj, URIS::HAS_RDF_TYPE, prospective_values)
          apply_delta(fedora_obj, URIS::HAS_RDF_TYPE, delta)
          return unless @hyacinth_obj.is_a? ::DigitalObject::Asset
          # Asset-only properties
          prospective_values = [@hyacinth_obj.content.original_filename].compact
          delta = delta(fedora_obj, URIS::ORIGINAL_FILENAME, prospective_values)
          apply_delta(fedora_obj, URIS::ORIGINAL_FILENAME, delta)
        end

        def parent_uris_for(hyacinth_obj)
          hyacinth_obj.parent_uids.map { |uid| ::DigitalObject.find(uid) }.compact.map do |parent|
            digital_object_pids(parent)
          end.flatten.compact
        end

        def project_string_keys_for(hyacinth_obj)
          hyacinth_obj.projects.map(&:string_key)
        end

        def publisher_string_keys_for(hyacinth_obj)
          hyacinth_obj.publish_entries.map { |string_key, _entry| string_key }
        end

        def dois_for(hyacinth_obj)
          return [] unless hyacinth_obj.doi
          [hyacinth_obj.doi].map { |x| x.start_with?("doi:") ? x : "doi:#{x}" }
        end

        def models_for(hyacinth_obj)
          models = []
          case hyacinth_obj.digital_object_type.downcase
          when 'asset'
            models << "info:fedora/ldpd:GenericResource"
          when 'group'
            models << "info:fedora/pcdm:Collection"
          when 'item'
            models << "info:fedora/ldpd:ContentAggregator"
          when 'site'
            models << "info:fedora/pcdm:Concept"
          end
          models
        end

        def rdf_types_for(hyacinth_obj)
          types = []
          case hyacinth_obj.digital_object_type.downcase
          when 'asset'
            types << "http://purl.oclc.org/NET/CUL/Resource"
          when 'group'
            types << "http://purl.oclc.org/NET/CUL/Aggregator"
          when 'item'
            types << "http://purl.oclc.org/NET/CUL/Aggregator"
          when 'site'
            types << "http://purl.oclc.org/NET/CUL/Aggregator"
          end
          types
        end

        def delta_for(fedora_obj, predicate, prospective_values)
          current_values = fedora_obj.relationship(predicate)
          deletes = current_values - prospective_values
          adds = prospective_values - current_values
          { :+ => adds, :- => deletes }
        end

        def apply_delta(fedora_obj, predicate, delta, options = {})
          repository = fedora_obj.repository
          delta.fetch(:-, []).each do |value|
            is_uri = (value =~ /^info\:/) || (value =~ /^https?\:/) || (value =~ /^doi\:/)
            rel_opts = { pid: fedora_obj.pid, predicate: predicate, object: value, isLiteral: !is_uri }
            repository.purge_relationship(options.merge(rel_opts))
          end
          delta.fetch(:+, []).each do |value|
            rel_opts = { pid: fedora_obj.pid, predicate: predicate, object: value }
            repository.add_relationship(options.merge(rel_opts))
          end
        end
      end
    end
  end
end
