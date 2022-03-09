# frozen_string_literal: true

module Types
  class SearchAttributes < Types::BaseInputObject
    description 'Shared Digital Object Search Params'

    argument :search_type, Enums::SearchTypeEnum, required: false
    argument :search_terms, String, required: false
    argument :filters, [FilterAttributes], required: false

    def as_search_adapter_params
      search_params = {}
      (@arguments[:filters] || []).each do |filter_attribute|
        (search_params[filter_attribute.field] ||= []) << [filter_attribute.values, filter_attribute.match_type]
      end
      search_params['search_type'] = @arguments[:search_type].blank? ? 'keyword' : @arguments[:search_type]
      search_params['q'] = @arguments[:search_terms]
      search_params
    end
  end
end
