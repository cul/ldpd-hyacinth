# frozen_string_literal: true

module Types
  class SearchAttributes < Types::BaseInputObject
    description 'Shared Digital Object Search Params'

    argument :search_type, Enums::SearchTypeEnum, required: false
    argument :search_terms, String, required: false
    argument :filters, [FilterAttributes, null: true], required: false

    def prepare
      search_params = {}
      (@arguments[:filters] || []).each do |filter_attribute|
        (search_params[filter_attribute.field] ||= []) << [filter_attribute.values, filter_attribute.match_type]
      end
      search_params['search_type'] = @arguments[:searchType].blank? ? 'keyword' : @arguments[:searchType]
      search_params['q'] = @arguments[:searchTerms]
      search_params
    end
  end
end
