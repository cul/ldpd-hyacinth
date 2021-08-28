# frozen_string_literal: true

module Hyacinth
  module Adapters
    module PreservationAdapter
      module Fedora3::TitleHelpers
        def get_title(object_data, opts = {})
          sort_portion = object_data.title&.fetch('sort_portion', nil)
          if sort_portion.present?
            non_sort_portion = object_data.title['non_sort_portion']
            opts[:sortable] ? sort_portion : "#{non_sort_portion}#{sort_portion}"
          else
            opts[:placeholder_if_blank] ? '[No Title]' : ''
          end
        end

        # Returns the sort portion of the primary title
        def get_sort_title(object_data, opts = {})
          get_title(object_data, opts.merge(sortable: true))
        end
      end
    end
  end
end
