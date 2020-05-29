# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Digital Objects Request' do
  subject(:graphql_request) { HyacinthSchema.execute(query, context: context, variables: {}) }
  let(:context) do
    {
      current_user: FactoryBot.create(:user),
      ability: nil
    }
  end

  context 'when no sort parameters' do
    let(:query) do
      <<~GQL
        query {
          digitalObjects(limit: 5) {
            nodes {
              id
            }
          }
        }
      GQL
    end

    it 'applies default sort parameters' do
      expect(
        Hyacinth::Config.digital_object_search_adapter.solr
      ).to receive(:get).with('select', params: hash_including(sort: 'score desc'))
      graphql_request
    end
  end

  context 'when sort parameters provided' do
    let(:query) do
      <<~GQL
        query {
          digitalObjects(limit: 5, orderBy: { field: TITLE, direction: ASC} ) {
            nodes {
              id
            }
          }
        }
      GQL
    end

    it 'applies sort parameters provided' do
      expect(
        Hyacinth::Config.digital_object_search_adapter.solr
      ).to receive(:get).with('select', params: hash_including(sort: 'sort_title_ssi asc'))
      graphql_request
    end
  end
end
