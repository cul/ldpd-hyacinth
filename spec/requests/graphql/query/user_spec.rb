# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Retrieve User', type: :request do
  let(:user) { FactoryBot.create(:user) }

  include_examples 'a basic user with no abilities is not authorized to perform this request' do
    let(:request) { graphql query(user.uid) }
  end

  context 'when logged in user has appropriate permissions' do
    before { sign_in_user as: :user_manager }

    context 'when uid is valid' do
      before { graphql query(user.uid) }

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
      before { graphql query('test-id') }

      it 'returns correct response' do
        expect(response.body).to be_json_eql(%("Couldn't find User")).at_path('errors/0/message')
      end
    end
  end

  def query(id)
    <<~GQL
      query {
        user(id: "#{id}") {
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
end
