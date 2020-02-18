# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::ExportJob::CreateExportJob, type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:search_params) do
    { 'param_one' => 'value one', 'param_2' => 'value two' }.to_json
  end

  context 'when user is logged in' do
    before { login_as user, scope: :user }

    context 'when creating a new export job' do
      let(:variables) do
        {
          input: {
            searchParams: search_params,
            userId: user.id
          }
        }
      end

      before { graphql query, variables }

      it 'returns correct response' do
        expect(response.body).to be_json_eql(%({
          "exportJob": { "searchParams": "#{search_params.gsub(/"/, '\"')}" }
        })).at_path('data/createExportJob')
      end
    end

    context 'when create request is missing searchParams' do
      let(:variables) { { input: {} } }

      before { graphql query, variables }

      it 'returns error' do
        expect(response.body).to be_json_eql(%(
           "Variable input of type CreateExportJobInput! was provided invalid value for userId (Expected value to not be null), searchParams (Expected value to not be null)"
        )).at_path('errors/0/message')
      end
    end
  end

  def query
    <<~GQL
      mutation ($input: CreateExportJobInput!) {
        createExportJob(input: $input) {
          exportJob {
            searchParams
          }
        }
      }
    GQL
  end
end
