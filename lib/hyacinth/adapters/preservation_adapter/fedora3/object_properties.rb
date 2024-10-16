# frozen_string_literal: true

module Hyacinth
  module Adapters
    module PreservationAdapter
      class Fedora3::ObjectProperties
        include Fedora3::PropertyContextInitializers

        def to(fedora_obj)
          fedora_obj.label = @hyacinth_obj.generate_display_label
          # no apparent state analog to Fedora 3's 'D' (deleted)
          fedora_obj.state = @hyacinth_obj.state == 'deleted' ? 'I' : 'A'
        end
      end
    end
  end
end
