# frozen_string_literal: true

module Hyacinth
  module Adapters
    module PreservationAdapter
      module Fedora3::TitleHelpers
        def get_title(descriptive_metadata, opts = {})
          title = descriptive_metadata['title']&.first && descriptive_metadata['title'].first['non_sort_portion'].present?
          title ||= ''
          title + get_sort_title(descriptive_metadata, opts)
        end

        # Returns the sort portion of the primary title
        def get_sort_title(descriptive_metadata, opts = {})
          if descriptive_metadata['title']&.first && descriptive_metadata['title'].first['sort_portion']
            descriptive_metadata['title'].first['sort_portion']
          else
            opts[:placeholder_if_blank] ? '[No Title]' : ''
          end
        end
      end
    end
  end
end
