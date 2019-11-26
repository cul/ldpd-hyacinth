# frozen_string_literal: true

module Hyacinth
  module Adapters
    module PreservationAdapter
      class Fedora3::RelsIntProperties
        module URIS
          EXTENT = "http://purl.org/dc/terms/extent".freeze
          HAS_MESSAGE_DIGEST = "http://www.loc.gov/premis/rdf/v1#hasMessageDigest".freeze
        end

        include Fedora3::PidHelpers

        def self.from(hyacinth_obj)
          new(hyacinth_obj)
        end

        def initialize(hyacinth_obj)
          @hyacinth_obj = hyacinth_obj
        end

        def to(fedora_obj)
          return unless @hyacinth_obj.is_a? ::DigitalObject::Asset
          ['master', 'service', 'access'].each do |dsid|
            resource = @hyacinth_obj.resources[dsid]
            apply_delta(fedora_obj, dsid, delta_for(resource, fedora_obj, dsid))
          end
        end

        def delta_for(resource, fedora_obj, dsid)
          proposed_values = {
            URIS::EXTENT => [resource.file_size],
            URIS::HAS_MESSAGE_DIGEST => [resource.checksum ? "urn:#{resource.checksum}" : nil]
          }

          proposed_values.each { |_k, v| v.compact! }

          current_values = current_rels_for(fedora_obj, dsid)
          delta = { :+ => {}, :- => {} }
          [URIS::EXTENT, URIS::HAS_MESSAGE_DIGEST].each do |prop|
            delta[:+][prop] = proposed_values[prop] - current_values[prop]
            delta[:-][prop] = current_values[prop] - proposed_values[prop]
          end
          delta
        end

        def current_rels_for(fedora_obj, dsid)
          repository = fedora_obj.repository
          subject = "info:fedora/#{fedora_obj.pid}/#{dsid}"
          values = {
            URIS::EXTENT => Array.wrap(repository.find_by_sparql_relationship(subject, URIS::EXTENT)),
            URIS::HAS_MESSAGE_DIGEST => Array.wrap(repository.find_by_sparql_relationship(subject, URIS::HAS_MESSAGE_DIGEST))
          }
          values.each { |_k, v| v.compact! }
          values
        end

        def apply_delta(fedora_obj, dsid, delta)
          repository = fedora_obj.repository
          subject = "info:fedora/#{fedora_obj.pid}/#{dsid}"
          delta.fetch(:-, {}).each do |predicate, values|
            is_literal = !predicate.to_s.eql?(URIS::HAS_MESSAGE_DIGEST.to_s)
            rel_opts = { pid: fedora_obj.pid, subject: subject, predicate: predicate, isLiteral: is_literal }
            values.each { |value| repository.purge_relationship(rel_opts.merge(object: value)) }
          end
          delta.fetch(:+, {}).each do |predicate, values|
            is_literal = !predicate.to_s.eql?(URIS::HAS_MESSAGE_DIGEST.to_s)
            rel_opts = { pid: fedora_obj.pid, subject: subject, predicate: predicate, isLiteral: is_literal }
            values.each { |value| repository.add_relationship(rel_opts.merge(object: value)) }
          end
        end
      end
    end
  end
end
