module Hyacinth
  module Adapters
    module PreservationAdapter
      module Fedora3::TitleHelpers
        def get_title(dynamic_field_data, opts = {})
          title = dynamic_field_data['title']&.first && dynamic_field_data['title'].first['title_non_sort_portion'].present?
          title ||= ''
          title + get_sort_title(dynamic_field_data, opts)
        end

        # Returns the sort portion of the primary title
        def get_sort_title(dynamic_field_data, opts = {})
          if dynamic_field_data['title']&.first && dynamic_field_data['title'].first['title_sort_portion']
            dynamic_field_data['title'].first['title_sort_portion']
          else
            opts[:placeholder_if_blank] ? '[No Title]' : ''
          end
        end
      end
    end
  end
end
