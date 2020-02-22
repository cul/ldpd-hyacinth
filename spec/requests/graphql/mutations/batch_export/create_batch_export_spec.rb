# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::BatchExport::CreateBatchExport, type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:mutation_search_params) do
    {
      'filters' => [
        {
          'field' => 'digital_object_type_ssi',
          'value' => 'asset'
        },
        {
          'field' => 'projects_ssim',
          'value' => 'test'
        }
      ]
    }
  end
  let(:expected_stored_search_params) do
    {
      'digital_object_type_ssi' => ['asset'],
      'projects_ssim' => ['test'],
      'q' => nil
    }
  end

  context 'when user is logged in' do
    before { login_as user, scope: :user }

    context 'when creating a new batch export' do
      let(:variables) do
        {
          input: {
            searchParams: mutation_search_params
          }
        }
      end

      before { graphql query, variables }

      it 'returns correct response' do
        json_response = JSON.parse(response.body)
        returned_search_params = JSON.parse(json_response.dig('data', 'createBatchExport', 'batchExport', 'searchParams'))
        expect(returned_search_params).to eq(expected_stored_search_params)
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
