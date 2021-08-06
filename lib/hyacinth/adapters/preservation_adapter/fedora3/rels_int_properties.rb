# frozen_string_literal: true

module Hyacinth
  module Adapters
    module PreservationAdapter
      class Fedora3::RelsIntProperties
        module URIS
          EXTENT = "http://purl.org/dc/terms/extent"
          HAS_MESSAGE_DIGEST = "http://www.loc.gov/premis/rdf/v1#hasMessageDigest"
        end

        include Fedora3::PropertyContextInitializers
        include Fedora3::PidHelpers

        def to(fedora_obj)
          return unless @hyacinth_obj.is_a? ::DigitalObject::Asset
          [:main_resource_name, :service_resource_name, :access_resource_name].each do |resource_name_method|
            resource_name = @hyacinth_obj.send resource_name_method
            dsid = adapter.resource_dsid_overrides.fetch(resource_name, resource_name)
            resource = @hyacinth_obj.resources[resource_name]
            apply_delta(fedora_obj, dsid, delta_for(resource, fedora_obj, dsid))
          end
        end

        def delta_for(resource, fedora_obj, dsid)
          proposed_values = {
            URIS::EXTENT => [resource && resource.file_size.present? ? resource.file_size : nil],
            URIS::HAS_MESSAGE_DIGEST => [resource && resource.checksum.present? ? "urn:#{resource.checksum}" : nil]
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
