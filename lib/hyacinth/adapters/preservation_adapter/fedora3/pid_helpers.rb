module Hyacinth
  module Adapters
    module PreservationAdapter
      module Fedora3::PidHelpers
        def digital_object_fedora_uris(hyacinth_obj)
          fcr3_uris = hyacinth_obj.preservation_target_uris.select { |x| x.start_with? Fedora3.uri_prefix }
          fcr3_uris.map { |fcr3_uri| "info:fedora/#{fcr3_uri[Fedora3.uri_prefix.length..-1]}" }
        end
      end
    end
  end
end
