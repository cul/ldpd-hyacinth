# frozen_string_literal: true

module Hyacinth
  module Adapters
    module PreservationAdapter
      class Fedora3::ObjectProperties
        include Fedora3::TitleHelpers
        include Fedora3::PropertyContextInitializers

        def to(fedora_obj)
          fedora_obj.label = get_title(@hyacinth_obj.descriptive_metadata)
          # no apparent state analog to Fedora 3's 'D' (deleted)
          fedora_obj.state = @hyacinth_obj.state == 'deleted' ? 'I' : 'A'
        end
      end
    end
  end
end
