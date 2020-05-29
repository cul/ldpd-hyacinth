# frozen_string_literal: true

class Enums::DigitalObject::OrderFieldsEnum < Types::BaseEnum
  value 'RELEVANCE', 'sorting by relevance score', value: 'score'
  value 'LAST_MODIFIED', 'sorting by last modified at', value: 'updated_at_dtsi'
  value 'TITLE', 'sorting by non-sort title', value: 'sort_title_ssi'
end
