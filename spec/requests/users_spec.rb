require 'rails_helper'

RSpec.describe 'User Requests', type: :request do
  describe 'GET /api/v1/users' do
    context 'when there are multiple results' do
      before do
        FactoryBot.create(:user)
        FactoryBot.create(:user, email: 'test-user@example.com')
        get '/api/v1/users'
      end

      it 'returns all users' do
        expect(response.body).to be_json_eql(%(
          [
            {
              "email": "jane-doe@example.com",
              "first_name": "Jane",
              "last_name": "Doe",
              "is_active": true,
              "groups": []},
            {
              "email": "test-user@example.com",
              "first_name": "Jane",
              "last_name": "Doe",
              "is_active": true,
              "groups": []
            }
          ]
        )).excluding(:uid)
      end

      it 'returns 200' do
        expect(response.status).to be 200
      end
    end

    describe 'when there are no results' do
      before { get '/api/v1/users' }

      it 'returns all users' do
        expect(response.body).to be_json_eql []
      end

      it 'returns 200' do
        expect(response.status).to be 200
      end
    end
  end

  describe 'GET /users/:uid' do
    context 'when uid is valid' do
      before do
        user = FactoryBot.create(:user)
        get "/api/v1/users/#{user.uid}"
      end

      it 'returns 200' do
        expect(response.status).to be 200
      end

      it 'returns correct response' do
        expect(response.body).to be_json_eql(%(
          {
            "email": "jane-doe@example.com",
            "first_name": "Jane",
            "last_name": "Doe",
            "is_active": true,
            "groups": []
          }
        )).excluding(:uid)
      end
    end

    context 'when uid is invalid' do
      before { get '/api/v1/users/test-uid' }

      it 'returns 404' do
        expect(response.status).to be 404
      end

      it 'returns correct response' do
        expect(response.body).to be_json_eql(%(
          { "errors": [{ "title": "Not Found" }] }
        ))
      end
    end
  end

  describe 'POST /api/v1/users' do
    context 'when creating a new user' do
      before do
        post '/api/v1/users', params: {
          first_name: 'Jane', last_name: 'Doe', email: 'jane.doe@example.com',
          password: 'bestpasswordever', password_confirmation: 'bestpasswordever'
        }
      end

      subject { User.first }

      its(:first_name) { is_expected.to eql 'Jane' }
      its(:last_name)  { is_expected.to eql 'Doe' }
      its(:email)      { is_expected.to eql 'jane.doe@example.com' }
      its(:is_active)  { is_expected.to be true }
      its(:uid)        { is_expected.not_to be_blank }

      it 'sets password' do
        expect(subject.valid_password?('bestpasswordever')).to be true
      end
    end

    context 'when creating a new user requires email' do
      before do
        post '/api/v1/users', params: {
          first_name: 'Jane', last_name: 'Doe',
          password: 'bestpasswordever', password_confirmation: 'bestpasswordever'
        }
      end

      it 'returns error' do
        expect(response.body).to be_json_eql(%(
          { "errors": [{ "title": "Email can't be blank" }] }
        ))
      end

      it 'returns 422' do
        expect(response.status).to be 422
      end
    end

    context 'when creating a new user requires password' do
      before do
        post '/api/v1/users', params: {
          first_name: 'Jane', last_name: 'Doe', email: 'jane.doe@example.com',
          password_confirmation: 'new_password'
        }
      end

      it 'returns error' do
        expect(response.body).to be_json_eql(%(
          {
            "errors": [
              { "title": "Password can't be blank" },
              { "title": "Password confirmation doesn't match Password" }
            ]
          }
        ))
      end

      it 'returns 422' do
        expect(response.status).to be 422
      end
    end

    context 'when creating a new user requires password_confirmation' do
      before do
        post '/api/v1/users', params: {
          first_name: 'Jane', last_name: 'Doe', email: 'jane.doe@example.com',
          password: 'new_password'
        }
      end

      it 'returns error' do
        expect(response.body).to be_json_eql(%(
          {
            "errors": [
              { "title": "Password confirmation can't be blank" }
            ]
          }
        ))
      end

      it 'returns 422' do
        expect(response.status).to be 422
      end
    end
  end

  describe 'PATCH /api/v1/users/:uid' do
    let(:user) { FactoryBot.create(:user) }

    context 'when updating first name' do
      before do
        patch "/api/v1/users/#{user.uid}", params: { first_name: 'John' }
      end

      it 'returns 200' do
        puts response.body
        expect(response.status).to be 200
      end

      it 'updates record' do
        user.reload
        expect(user.first_name).to eql 'John'
      end
    end

    context 'when updating last name' do
      before do
        patch "/api/v1/users/#{user.uid}", params: { last_name: 'Smith' }
      end

      it 'returns 200' do
        expect(response.status).to be 200
      end

      it 'updates record' do
        user.reload
        expect(user.last_name).to eql 'Smith'
      end
    end

    context 'when updating email' do
      before do
        patch "/api/v1/users/#{user.uid}", params: { email: 'jane.doe@library.columbia.edu' }
      end

      it 'returns 200' do
        expect(response.status).to be 200
      end

      it 'updates record' do
        user.reload
        expect(user.email).to eql 'jane.doe@library.columbia.edu'
      end
    end

    context 'when updating is_active' do
      context 'when a user manager is logged in' do
        it 'can update is_active'
      end

      context 'when a regular user is logged in' do
        it 'cannot update is_active'
      end
    end

    context 'when updating password' do
      before do
        patch "/api/v1/users/#{user.uid}", params: {
          current_password: 'terriblepassword',
          password: 'newpassword', password_confirmation: 'newpassword'
        }
      end

      it 'update record' do
        user.reload
        expect(user.valid_password?('newpassword')).to be true
      end

      it 'returns 200' do
        expect(response.status).to be 200
      end
    end

    context 'when updating password without password confirmation' do
      before do
        patch "/api/v1/users/#{user.uid}", params: {
          current_password: 'terriblepassword', password: 'newpassword'
        }
      end

      it 'does not update record' do
        user.reload
        expect(user.valid_password?('newpassword')).to be false
      end

      it 'returns 422' do
        expect(response.status).to be 422
      end
    end

    context 'when updating :uid' do
      let(:uid) { user.uid }

      before do
        patch "/api/v1/users/#{uid}", params: { uid: 'new-uuid' }
      end

      it 'does not update record' do
        user.reload
        expect(user.uid).to eql uid
      end
    end
  end
end
