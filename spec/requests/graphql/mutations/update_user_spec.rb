require 'rails_helper'

RSpec.describe Mutations::UpdateUser, type: :request do
  describe '.resolve' do
    let(:user) { FactoryBot.create(:user) }

    include_examples 'requires user to have correct permissions for graphql request' do
      let(:query) do
        <<~GQL
          mutation {
            updateUser(
              input: {
                id: "#{user.uid}"
                firstName: "John"
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

    context 'when logged in user is not an administrator or user manager' do
      let(:query) do
        <<~GQL
          mutation {
            updateUser(
              input: {
                id: "#{user.uid}"
                firstName: "John"
                lastName: "Doe"
                email: "john.doe@example.com"
                isActive: false
              }
            ) {
              user {
                id
              }
            }
          }
        GQL
      end

      before do
        login_as user, scope: :user
        graphql query: query
        user.reload
      end

      it 'cannot update is_active for its own record' do
        expect(user.is_active).to be true
      end

      it 'can update first name' do
        expect(user.first_name).to eql 'John'
      end

      it 'can update last name' do
        expect(user.last_name).to eql 'Doe'
      end

      it 'can update email' do
        expect(user.email).to eql 'john.doe@example.com'
      end
    end

    context 'when logged in user is administrator' do
      before { sign_in_user as: :administrator }

      context 'when updating is_admin' do
        let(:query) do
          <<~GQL
            mutation {
              updateUser(
                input: {
                  id: "#{user.uid}"
                  isAdmin: true
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

        it 'updates record' do
          user.reload
          expect(user.is_admin).to be true
        end
      end

      context 'when changing permissions' do
        subject(:actions) do
          user.reload
          user.permissions.map(&:action)
        end

        before do
          Permission.create(user: user, action: Permission::MANAGE_USERS)
          user.reload
        end

        context 'with missing permission key' do
          let(:query) do
            <<~GQL
              mutation {
                updateUser(
                  input: {
                    id: "#{user.uid}"
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

          it 'permissions aren\'t updated' do
            expect(actions).to match_array [Permission::MANAGE_USERS]
          end
        end

        context 'with empty permissions array' do
          let(:query) do
            <<~GQL
              mutation {
                updateUser(
                  input: {
                    id: "#{user.uid}"
                    permissions: []
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

          it 'removes all permissions' do
            expect(actions).to match_array []
          end
        end

        context 'by removing and adding permission' do
          let(:query) do
            <<~GQL
              mutation {
                updateUser(
                  input: {
                    id: "#{user.uid}"
                    permissions: ["#{Permission::READ_ALL_DIGITAL_OBJECTS}"]
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

          it 'updates permissions correctly' do
            expect(actions).to match_array [Permission::READ_ALL_DIGITAL_OBJECTS]
          end
        end

        context 'by adding permission' do
          let(:query) do
            <<~GQL
              mutation {
                updateUser(
                  input: {
                    id: "#{user.uid}"
                    permissions: ["#{Permission::MANAGE_USERS}", "#{Permission::READ_ALL_DIGITAL_OBJECTS}"]
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

          it 'updates permission correctly' do
            expect(actions).to match_array [Permission::MANAGE_USERS, Permission::READ_ALL_DIGITAL_OBJECTS]
          end
        end

        context 'when updating with invalid permissions' do
          let(:query) do
            <<~GQL
              mutation {
                updateUser(
                  input: {
                    id: "#{user.uid}"
                    permissions: ["not_valid"]
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

          it 'does not update permissions' do
            expect(actions).to match_array [Permission::MANAGE_USERS]
          end
        end
      end
    end

    context 'when logged in user is user manager' do
      before { sign_in_user as: :user_manager }

      context 'when updating attributes' do
        let(:query) do
          <<~GQL
            mutation {
              updateUser(
                input: {
                  id: "#{user.uid}"
                  firstName: "John"
                  lastName: "Smith"
                  email: "jane.doe@library.columbia.edu"
                }
              ) {
                user {
                  id
                }
              }
            }
          GQL
        end

        before do
          graphql query: query
          user.reload
        end

        it 'updates first name' do
          expect(user.first_name).to eql 'John'
        end

        it 'updates last name' do
          expect(user.last_name).to eql 'Smith'
        end

        it 'updates email' do
          expect(user.email).to eql 'jane.doe@library.columbia.edu'
        end
      end

      context 'when updating password' do
        let(:query) do
          <<~GQL
            mutation {
              updateUser(
                input: {
                  id: "#{user.uid}"
                  currentPassword: "terriblepassword"
                  password: "newpassword"
                  passwordConfirmation: "newpassword"
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

        it 'update record' do
          user.reload
          expect(user.valid_password?('newpassword')).to be true
        end
      end

      context 'when updating password without password confirmation' do
        let(:query) do
          <<~GQL
            mutation {
              updateUser(
                input: {
                  id: "#{user.uid}"
                  current_password: "terriblepassword"
                  password: "newpassword"
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

        it 'does not update record' do
          user.reload
          expect(user.valid_password?('newpassword')).to be false
        end
      end

      context 'when updating :is_active' do
        let(:query) do
          <<~GQL
            mutation {
              updateUser(
                input: {
                  id: "#{user.uid}"
                  isActive: false
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

        it 'updates record' do
          user.reload
          expect(user.is_active).to be false
        end
      end

      context 'when updating :permissions' do
        let(:query) do
          <<~GQL
            mutation {
              updateUser(
                input: {
                  id: "#{user.uid}"
                  permissions: ["#{Permission::MANAGE_USERS}"]
                }
              ) {
                user {
                  id
                }
              }
            }
          GQL
        end

        it 'does not update record' do
          user.reload
          expect(user.permissions).to match_array []
        end
      end

      context 'when updating :is_admin' do
        let(:query) do
          <<~GQL
            mutation {
              updateUser(
                input: {
                  id: "#{user.uid}"
                  isAdmin: true
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

        it 'does not update record' do
          user.reload
          expect(user.is_admin).to be false
        end
      end
    end
  end
end
