# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::SwitchToUser, type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:user_uid) { user.uid }
  let(:variables) do
    {
      'input': {
        'id': user_uid
      }
    }
  end

  include_examples 'a basic user with no abilities is not authorized to perform this request' do
    let(:request) { graphql query, variables }
  end

  context 'when logged in user is an administrator' do
    before do
      sign_in_user as: :administrator
      graphql query, variables
    end

    context 'when switching to a user that exists' do
      it 'is successful' do
        expect(response.body).to be_json_eql(%(
          {
            "success": true
          }
        )).at_path('data/switchToUser')
      end
    end

    context 'when switching to a user that does not exist' do
      let(:user_uid) { 'no-user-exists-with-this-id' }

      it 'returns an error message' do
        expect(response.body).to be_json_eql(%(
          "Couldn't find User"
        )).at_path('errors/0/message')
      end
    end
  end

  def query
    <<~GQL
      mutation ($input: SwitchToUserInput!) {
        switchToUser(input: $input) {
          success
        }
      }
    GQL
  end
end
