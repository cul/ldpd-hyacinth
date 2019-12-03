# frozen_string_literal: true

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

  context 'when logged in user has no permissions' do
    before do
      sign_in_user
      FactoryBot.create(:user)
      graphql query
    end

    it 'returns only the logged in user' do
      expect(response.body).to be_json_eql(%({
        "users" : [
          {
            "email": "logged-in-user@exaple.com",
            "firstName": "Signed In",
            "lastName": "User",
            "isActive": true,
            "isAdmin": false,
            "permissions": []
          }
        ]
      })).at_path('data')
    end
  end

  context 'when logged in user has appropriate permissions' do
    before { sign_in_user as: :user_manager }

    context 'when there are multiple results' do
      before do
        FactoryBot.create(:user)
        graphql(query)
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
