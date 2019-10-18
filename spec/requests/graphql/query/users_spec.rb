require 'rails_helper'

RSpec.describe 'Retrieve Users', type: :request do
  let(:query) do
    <<~GQL
      query {
        users {
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

  include_examples 'requires user to have correct permissions for graphql request' do
    let(:request) { graphql query: query }
  end

  context 'when logged in user has appropriate permissions' do
    before { sign_in_user as: :user_manager }

    context 'when there are multiple results' do
      before do
        FactoryBot.create(:user)
        graphql query: query
      end

      it 'returns all users' do
        expect(response.body).to be_json_eql(%({
          "users" : [
            {
              "email": "jane-doe@example.com",
              "firstName": "Jane",
              "lastName": "Doe",
              "isActive": true,
              "isAdmin": false,
              "permissions": []
            },
            {
              "email": "logged-in-user@exaple.com",
              "firstName": "Signed In",
              "lastName": "User",
              "isActive": true,
              "isAdmin": false,
              "permissions": ["manage_users"]
            }
          ]
        })).at_path('data')
      end
    end
  end
end
