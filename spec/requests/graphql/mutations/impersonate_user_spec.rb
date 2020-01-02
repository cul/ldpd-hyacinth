# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::ImpersonateUser, type: :request do
  let(:user_to_impersonate) { FactoryBot.create(:user) }
  # let(:non_admin_user) { FactoryBot.create(:user) }
  # let(:admin_user) { FactoryBot.create(:user, :administrator) }

  let(:variables) do
    {
      input: {
        id: user_to_impersonate.uid
      }
    }
  end

  include_examples 'requires user to have correct permissions for graphql request' do
    let(:request) { graphql query, variables }
  end

  context 'when logged in user is an admin' do
    before do
      sign_in_user as: :administrator
      graphql query, variables
    end

    it 'returns a successful response' do
      # Expect a successful response
      expect(response.body).to be_json_eql(%({
        "impersonateUser": {
          "success": true
        }
      })).at_path('data')
    end

    context "returns that impersonated user's uid for an authenticatedUser query" do
      before do
        graphql authenticated_user_query
      end

      it do
        # Expect a query for the currently authenticated user to return the impersonated user's id
        expect(response.body).to be_json_eql(%({
          "authenticatedUser": {
            "id": "#{user_to_impersonate.uid}"
          }
        })).at_path('data')
      end
    end
  end

  context 'when logged in user is not an admin' do
    before do
      sign_in_user
      graphql query, variables
    end

    it 'returns error' do
      expect(response.body).to be_json_eql(%(
        "You are not authorized to access this page."
      )).at_path('errors/0/message')
    end
  end

  def query
    <<~GQL
      mutation ImpersonateUser($input: ImpersonateUserInput!) {
        impersonateUser(input: $input) {
          success
        }
      }
    GQL
  end

  def authenticated_user_query
    <<~GQL
      query AuthenticatedUser {
        authenticatedUser {
          id
        }
      }
    GQL
  end
end
