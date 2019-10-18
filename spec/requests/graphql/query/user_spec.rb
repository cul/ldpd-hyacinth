require 'rails_helper'

RSpec.describe 'Retrieve User', type: :request do
  let(:user) { FactoryBot.create(:user) }

  include_examples 'requires user to have correct permissions for graphql request' do
    let(:query) do
      <<~GQL
        query {
          user(id: "#{user.uid}") {
            email
          }
        }
      GQL
    end
    let(:request) { graphql query: query }
  end

  context 'when logged in user has appropriate permissions' do
    before { sign_in_user as: :user_manager }

    context 'when uid is valid' do
      let(:query) do
        <<~GQL
          query {
            user(id: "#{user.uid}") {
              email
              firstName
              lastName
              isActive
              isAdmin
              permissions
            }
          }
        GQL
      end

      before { graphql query: query }

      it 'returns correct response' do
        expect(response.body).to be_json_eql(%({
          "user": {
            "email": "jane-doe@example.com",
            "firstName": "Jane",
            "lastName": "Doe",
            "isActive": true,
            "isAdmin": false,
            "permissions": []
          }
        })).at_path('data')
      end
    end

    context 'when uid is invalid' do
      let(:query) do
        <<~GQL
          query {
            user(id: "test-id") {
              email
            }
          }
        GQL
      end

      before { graphql query: query }

      it 'returns correct response' do
        expect(response.body).to be_json_eql(%("Couldn't find User")).at_path('errors/0/message')
      end
    end
  end
end
