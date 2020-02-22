# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::BatchExport::CreateBatchExport, type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:search_params) do
    { 'param_one' => 'value one', 'param_2' => 'value two' }
  end

  context 'when user is logged in' do
    before { login_as user, scope: :user }

    context 'when creating a new batch export' do
      let(:variables) do
        {
          input: {
            searchParams:  {
              filters: search_params.map { |k, v| { field: k, value: v } }
            }
          }
        }
      end

      before { graphql query, variables }

      it 'returns correct response' do
        json_response = JSON.parse(response.body)
        returned_params = JSON.parse(json_response.dig('data', 'createBatchExport', 'batchExport', 'searchParams'))
        expect(returned_params).to include(search_params.map { |k, v| [k, [v]] }.to_h)
      end
    end

    context 'when create request is missing searchParams' do
      let(:variables) { { input: {} } }

      before { graphql query, variables }

      it 'returns error' do
        expect(response.body).to be_json_eql(%(
           "Variable input of type CreateBatchExportInput! was provided invalid value for searchParams (Expected value to not be null)"
        )).at_path('errors/0/message')
      end
    end
  end

  def query
    <<~GQL
      mutation ($input: CreateBatchExportInput!) {
        createBatchExport(input: $input) {
          batchExport {
            searchParams
          }
        }
      }
    GQL
  end
end
