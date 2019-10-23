require 'rails_helper'

RSpec.describe Mutations::CreateUser, type: :request do
  describe '.resolve' do
    include_examples 'requires user to have correct permissions for graphql request' do
      let(:variables) do
        <<~VAR
          {
            "input": {
              "firstName": "Jane",
              "lastName": "Doe",
              "email": "jane.doe@example.com",
              "password": "bestpasswordever",
              "passwordConfirmation": "bestpasswordever"
            }
          }
        VAR
      end

      let(:request) { graphql query, variables }
    end

    context 'when logged in user has appropriate permissions' do
      before { sign_in_user as: :user_manager }

      context 'when creating a new user' do
        subject(:user) { User.find_by(email: email) }

        let(:email) { 'jane.doe@example.com' }
        let(:variables) do
          <<~VAR
            {
              "input": {
                "firstName": "Jane",
                "lastName": "Doe",
                "email": "#{email}",
                "password": "bestpasswordever",
                "passwordConfirmation": "bestpasswordever"
              }
            }
          VAR
        end

        # permissions: [#{Permission::MANAGE_USERS}, #{Permission::MANAGE_VOCABULARIES}]

        before { graphql query, variables }

        its(:first_name) { is_expected.to eql 'Jane' }
        its(:last_name)  { is_expected.to eql 'Doe' }
        its(:email)      { is_expected.to eql 'jane.doe@example.com' }
        its(:is_active)  { is_expected.to be true }
        its(:uid)        { is_expected.not_to be_blank }

        it 'sets password' do
          expect(user.valid_password?('bestpasswordever')).to be true
        end

        # it 'creates permisisons' do
        #   expect(user.permissions.map(&:action)).to match_array [Permission::MANAGE_USERS, Permission::MANAGE_VOCABULARIES]
        # end
      end

      context 'when creating a new user requires email' do
        let(:variables) do
          <<~VAR
            {
              "input": {
                "firstName": "Jane",
                "lastName": "Doe",
                "password": "bestpasswordever",
                "passwordConfirmation": "bestpasswordever"
              }
            }
          VAR
        end

        before { graphql query, variables }

        it 'returns error' do
          expect(response.body).to be_json_eql(%(
            "Variable input of type CreateUserInput! was provided invalid value for email (Expected value to not be null)"
          )).at_path('errors/0/message')
        end
      end

      context 'when creating a new user requires password' do
        let(:variables) do
          <<~VAR
            {
              "input": {
                "firstName": "Jane",
                "lastName": "Doe",
                "email": "jane.doe@example.com",
                "passwordConfirmation": "bestpasswordever"
              }
            }
          VAR
        end

        before { graphql query, variables }

        it 'returns error' do
          expect(response.body).to be_json_eql(%(
            "Variable input of type CreateUserInput! was provided invalid value for password (Expected value to not be null)"
          )).at_path('errors/0/message')
        end
      end

      context 'when creating a new user requires password_confirmation' do
        let(:variables) do
          <<~VAR
            {
              "input": {
                "firstName": "Jane",
                "lastName": "Doe",
                "email": "jane.doe@example.com",
                "password": "bestpasswordever"
              }
            }
          VAR
        end

        before { graphql query, variables }

        it 'returns error' do
          expect(response.body).to be_json_eql(%(
            "Variable input of type CreateUserInput! was provided invalid value for passwordConfirmation (Expected value to not be null)"
          )).at_path('errors/0/message')
        end
      end
    end

    def query
      <<~GQL
        mutation ($input: CreateUserInput!) {
          createUser(input: $input) {
            user {
              id
            }
          }
        }
      GQL
    end
  end
end
