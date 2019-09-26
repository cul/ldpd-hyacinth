require 'rails_helper'

RSpec.describe Mutations::CreateUser, type: :request do
  describe '.resolve' do
    include_examples 'requires user to have correct permissions for graphql request' do
      let(:query) do
        <<~GQL
          mutation {
            createUser(
              input: {
                firstName: "Jane"
                lastName: "Doe"
                email: "jane.doe@example.com"
                password: "bestpasswordever"
                passwordConfirmation: "bestpasswordever"
              }
            ) {
              user {
                id
              }
            }
          }
        GQL
      end
      let(:request) { graphql query: query }
    end

    context 'when logged in user has appropriate permissions' do
      before { sign_in_user as: :user_manager }

      context 'when creating a new user' do
        let(:email) { 'jane.doe@example.com' }
        let(:query) do
          <<~GQL
            mutation {
              createUser(
                input: {
                  firstName: "Jane"
                  lastName: "Doe"
                  email: "#{email}"
                  password: "bestpasswordever"
                  passwordConfirmation: "bestpasswordever"
                }
              ) {
                user {
                  id
                }
              }
            }
          GQL
        end

        # permissions: [#{Permission::MANAGE_USERS}, #{Permission::MANAGE_VOCABULARIES}]

        before { graphql query: query }

        subject { User.find_by(email: email) }

        its(:first_name) { is_expected.to eql 'Jane' }
        its(:last_name)  { is_expected.to eql 'Doe' }
        its(:email)      { is_expected.to eql 'jane.doe@example.com' }
        its(:is_active)  { is_expected.to be true }
        its(:uid)        { is_expected.not_to be_blank }

        it 'sets password' do
          expect(subject.valid_password?('bestpasswordever')).to be true
        end

        # it 'creates permisisons' do
        #   expect(subject.permissions.map(&:action)).to match_array [Permission::MANAGE_USERS, Permission::MANAGE_VOCABULARIES]
        # end
      end

      context 'when creating a new user requires email' do
        let(:query) do
          <<~GQL
            mutation {
              createUser(
                input: {
                  firstName: "Jane"
                  lastName: "Doe"
                  password: "bestpasswordever"
                  passwordConfirmation: "bestpasswordever"
                }
              ) {
                user {
                  id
                }
              }
            }
          GQL
        end

        before { graphql query: query }

        it 'returns error' do
          expect(response.body).to be_json_eql(%(
            "Argument 'email' on InputObject 'CreateUserInput' is required. Expected type String!"
          )).at_path('errors/0/message')
        end
      end

      context 'when creating a new user requires password' do
        let(:query) do
          <<~GQL
            mutation {
              createUser(
                input: {
                  firstName: "Jane"
                  lastName: "Doe"
                  email: "jane.doe@example.com"
                  passwordConfirmation: "bestpasswordever"
                }
              ) {
                user {
                  id
                }
              }
            }
          GQL
        end

        before { graphql query: query }

        it 'returns error' do
          expect(response.body).to be_json_eql(%(
            "Argument 'password' on InputObject 'CreateUserInput' is required. Expected type String!"
          )).at_path('errors/0/message')
        end
      end

      context 'when creating a new user requires password_confirmation' do
        let(:query) do
          <<~GQL
            mutation {
              createUser(
                input: {
                  firstName: "Jane"
                  lastName: "Doe"
                  email: "jane.doe@example.com"
                  password: "bestpasswordever"
                }
              ) {
                user {
                  id
                }
              }
            }
          GQL
        end

        before { graphql query: query }

        it 'returns error' do
          expect(response.body).to be_json_eql(%(
            "Argument 'passwordConfirmation' on InputObject 'CreateUserInput' is required. Expected type String!"
          )).at_path('errors/0/message')
        end
      end
    end
  end
end
