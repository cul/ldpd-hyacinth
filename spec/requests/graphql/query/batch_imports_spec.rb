# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Retrieving Batch Imports', type: :request do
  context "when logged in user is administrator" do
    let(:expected_response) do
      %(
        [
          {
            "fileLocation": "managed-disk://path/to/file",
            "status": "in_progress",
            "priority": "high",
            "user": {
              "firstName": "Jane",
              "lastName": "Doe"
            }
          },
          {
            "fileLocation": "managed-disk://path/to/file",
            "status": "in_progress",
            "priority": "high",
            "user": {
              "firstName": "Signed In",
              "lastName": "User"
            }
          }
        ]
      )
    end

    before do
      sign_in_user as: :administrator
      FactoryBot.create(:batch_import, user: User.first)
      FactoryBot.create(:batch_import)
      graphql query
    end

    it "returns all batch imports" do
      expect(response.body).to be_json_eql(expected_response).at_path('data/batchImports/nodes')
    end
  end

  context "when user is logged in" do
    let(:expected_response) do
      %(
        [
          {
            "fileLocation": "managed-disk://path/to/file",
            "status": "in_progress",
            "priority": "high",
            "user": {
              "firstName": "Signed In",
              "lastName": "User"
            }
          }
        ]
      )
    end

    before do
      sign_in_user
      FactoryBot.create(:batch_import, user: User.first)
      FactoryBot.create(:batch_import)
      graphql query
    end

    it "returns batch imports created by logged in user" do
      expect(response.body).to be_json_eql(expected_response).at_path('data/batchImports/nodes')
    end
  end

  def query
    <<~GQL
      query {
        batchImports(limit: 5) {
          nodes {
            id
            fileLocation
            status
            priority
            user {
              id
              firstName
              lastName
            }
          }
        }
      }
    GQL
  end
end
