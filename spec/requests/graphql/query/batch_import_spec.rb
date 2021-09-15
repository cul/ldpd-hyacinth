# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Retrieving Batch Import', type: :request do
  include_examples 'a basic user with no abilities is not authorized to perform this request' do
    let(:batch_import) { FactoryBot.create(:batch_import) }
    let(:request) { graphql query(batch_import.id) }
  end

  context 'when user is logged in' do
    context 'when id is valid' do
      let(:batch_import) { FactoryBot.create(:batch_import, :with_digital_object_import, user: User.first) }
      let(:expected_response) do
        %(
          {
            "fileLocation": "managed-disk://path/to/file",
            "priority": "HIGH",
            "status": "PENDING",
            "numberOfPendingImports": 1,
            "numberOfInProgressImports": 0,
            "numberOfSuccessImports": 0,
            "numberOfCreationFailureImports": 0,
            "numberOfUpdateFailureImports": 0,
            "numberOfPersistFailureImports": 0,
            "numberOfPublishFailureImports": 0,
            "originalFilename": "import.csv",
            "user": {
              "firstName": "Signed In",
              "lastName": "User"
            }
          }
        )
      end

      before do
        sign_in_user
        graphql query(batch_import.id)
      end

      it "returns batch import" do
        expect(response.body).to be_json_eql(expected_response).at_path('data/batchImport')
      end
    end

    context 'when id is invalid' do
      before do
        sign_in_user
        graphql query("12345")
      end

      it "returns error" do
        expect(response.body).to be_json_eql(%(
          "Couldn't find BatchImport with 'id'=12345"
        )).at_path('errors/0/message')
      end
    end
  end

  def query(id)
    <<~GQL
      query {
        batchImport(id: "#{id}") {
          id
          originalFilename
          fileLocation
          status
          priority
          numberOfPendingImports
          numberOfInProgressImports
          numberOfSuccessImports
          numberOfCreationFailureImports
          numberOfUpdateFailureImports
          numberOfPersistFailureImports
          numberOfPublishFailureImports
          user {
            id
            firstName
            lastName
          }
        }
      }
    GQL
  end
end
