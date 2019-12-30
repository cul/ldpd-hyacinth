# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Retrieve Users', type: :request do
  let(:query) do
    <<~GQL
      query {
        users {
          email
          firstName
          middleName
          lastName
          fullName
          sortName
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
            "middleName": null,
            "lastName": "User",
            "fullName": "Signed In User",
            "sortName": "User, Signed In",
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
        FactoryBot.create(:user, email: 'jane-a-doe@example.com', middle_name: 'A')
        FactoryBot.create(:user, email: 'jane-z-doe@example.com', middle_name: 'Z')
        FactoryBot.create(:user, email: 'jane-b-doe@example.com', middle_name: 'B')
        FactoryBot.create(:user, email: 'abigail-q-doe@example.com', first_name: 'Abigail', middle_name: 'Q')
        graphql(query)
      end

      it 'returns all users in the correct name-sorted order' do
        expect(response.body).to be_json_eql(%({
          "users" : [
            {
              "email": "abigail-q-doe@example.com",
              "firstName": "Abigail",
              "middleName": "Q",
              "lastName": "Doe",
              "fullName": "Abigail Q Doe",
              "sortName": "Doe, Abigail Q",
              "isActive": true,
              "isAdmin": false,
              "permissions": []
            },
            {
              "email": "jane-doe@example.com",
              "firstName": "Jane",
              "middleName": null,
              "lastName": "Doe",
              "fullName": "Jane Doe",
              "sortName": "Doe, Jane",
              "isActive": true,
              "isAdmin": false,
              "permissions": []
            },
            {
              "email": "jane-a-doe@example.com",
              "firstName": "Jane",
              "middleName": "A",
              "lastName": "Doe",
              "fullName": "Jane A Doe",
              "sortName": "Doe, Jane A",
              "isActive": true,
              "isAdmin": false,
              "permissions": []
            },
            {
              "email": "jane-b-doe@example.com",
              "firstName": "Jane",
              "middleName": "B",
              "lastName": "Doe",
              "fullName": "Jane B Doe",
              "sortName": "Doe, Jane B",
              "isActive": true,
              "isAdmin": false,
              "permissions": []
            },
            {
              "email": "jane-z-doe@example.com",
              "firstName": "Jane",
              "middleName": "Z",
              "lastName": "Doe",
              "fullName": "Jane Z Doe",
              "sortName": "Doe, Jane Z",
              "isActive": true,
              "isAdmin": false,
              "permissions": []
            },
            {
              "email": "logged-in-user@exaple.com",
              "firstName": "Signed In",
              "middleName": null,
              "lastName": "User",
              "fullName": "Signed In User",
              "sortName": "User, Signed In",
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
