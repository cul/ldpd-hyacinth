require 'rails_helper'

RSpec.describe 'Group Requests', type: :request do
  describe 'GET /api/v1/groups' do
    describe 'when there are multiple results' do
      before do
        FactoryBot.create(:group)
        FactoryBot.create(:group, string_key: 'content_managers')
        get '/api/v1/groups'
      end

      it 'returns all groups' do
        expect(response.body).to be_json_eql(%(
          [
            { "string_key": "developers"},
            { "string_key": "content_managers"}
          ]
        ))
      end

      it 'returns 200' do
        expect(response.status).to be 200
      end
    end

    describe 'when there are no results' do
      before { get '/api/v1/groups' }

      it 'returns all users' do
        expect(response.body).to be_json_eql(%([]))
      end

      it 'returns 200' do
        expect(response.status).to be 200
      end
    end
  end

  describe 'GET /api/v1/groups/:string_key' do
    context 'when string_key is valid' do
      before do
        group = FactoryBot.create(:group)
        get "/api/v1/groups/#{group.string_key}"
      end

      it 'returns 200' do
        expect(response.status).to be 200
      end

      it 'returns correct response' do
        expect(response.body).to be_json_eql(%(
          { "string_key": "developers" }
        ))
      end
    end

    context 'when string_key is invalid' do
      before { get '/api/v1/groups/not_valid' }

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

  describe 'POST /api/v1/groups' do
    context 'when creating a new group' do
      before do
        post '/api/v1/groups', params: { string_key: 'content_managers' }
      end

      it 'returns 201' do
        expect(response.status).to be 201
      end

      it 'returns correct response' do
        expect(response.body).to be_json_eql(%({
          "string_key": "content_managers"
        }))
      end
    end

    context 'when creating requires string_key' do
      before do
        post '/api/v1/groups', params: {}
      end

      it 'returns 422' do
        expect(response.status).to be 422
      end

      it 'returns error' do
        expect(response.body).to be_json_eql(%(
         {
           "errors": [
             { "title": "String key can't be blank" }
           ]
         }
        ))
      end
    end

    context 'when creating with invalid string_key' do
      before do
        post '/api/v1/groups', params: { string_key: 'ContentManagers' }
      end

      it 'returns 422' do
        expect(response.status).to be 422
      end

      it 'returns error' do
        expect(response.body).to be_json_eql(%(
          {
            "errors": [
              { "title": "String key only allows lowercase alphanumeric characters and underscores and must start with a lowercase letter" }
            ]
          }
        ))
      end
    end
  end

  describe 'PATCH /api/v1/groups/:string_key' do
    let(:user)  { FactoryBot.create(:user) }
    let(:group) { FactoryBot.create(:group) }

    context 'when updating with invalid user_ids' do
      before do
        patch "/api/v1/groups/#{group.string_key}", params: { user_ids: ['123-134-194-938-938'] }
      end

      it 'does not update group' do
        group.reload
        expect(group.users).to be_empty
      end

      it 'returns errors' do
        expect(response.body).to be_json_eql(%(
          {
            "errors": [
              { "title": "User uid 123-134-194-938-938 not valid." }
            ]
          }
        ))
      end

      it 'returns 422' do
        expect(response.status).to be 422
      end
    end

    context 'when updating with valid user_ids' do
      before do
        patch "/api/v1/groups/#{group.string_key}", params: { user_ids: [user.uid] }
      end

      it 'returns 200' do
        expect(response.status).to be 200
      end

      it 'updates record' do
        group.reload
        expect(group.users).to match_array([user])
      end
    end

    context 'when updating with invalid permissions' do
      before do
        patch "/api/v1/groups/#{group.string_key}", params: { permissions: ['manage_everything'] }
      end

      it 'returns error' do
        expect(response.body).to be_json_eql(%(
          {
            "errors": [{ "title": "Permission manage_everything is not valid." }]
          }
        ))
      end

      it 'returns 422' do
        expect(response.status).to be 422
      end

      it 'does not update record' do
        group.reload
        expect(group.permissions).to be_empty
      end
    end

    context 'when updating with valid permissions' do
      before do
        patch "/api/v1/groups/#{group.string_key}", params: {
          permissions: [Permission::MANAGE_ALL_DIGITAL_OBJECTS]
        }
      end

      it 'return 200' do
        expect(response.status).to be 200
      end

      it 'updates record' do
        group.reload
        expect(group.permissions.first.action).to eql Permission::MANAGE_ALL_DIGITAL_OBJECTS
      end
    end

    context 'when attempting to update string_key' do
      before do
        patch "/api/v1/groups/#{group.string_key}", params: { string_key: 'administrators' }
      end

      it 'does not update record' do
        group.reload
        expect(group.string_key).to eql 'developers'
      end
    end

    context 'when updating user_ids and permissions' do
      let(:user) { FactoryBot.create(:user) }
      let(:user2) { FactoryBot.create(:user, email: 'new-test-user@example.com') }

      before do
        Permission.create(group: group, action: Permission::MANAGE_USERS)
        Permission.create(group: group, action: Permission::MANAGE_GROUPS)
        group.users << user

        patch "/api/v1/groups/#{group.string_key}", params: {
          permissions: [
            Permission::MANAGE_GROUPS,
            Permission::MANAGE_GROUPS,
            Permission::MANAGE_ALL_DIGITAL_OBJECTS
          ],
          user_ids: [user.uid, user2.uid]
        }
      end

      it 'updates group permissions' do
        group.reload
        expect(
          group.permissions.map(&:action)
        ).to match_array([
          Permission::MANAGE_GROUPS,
          Permission::MANAGE_GROUPS,
          Permission::MANAGE_ALL_DIGITAL_OBJECTS
        ])
      end

      it 'updated group users' do
        group.reload
        expect(group.users).to match_array [user, user2]
      end

      it 'returns 200' do
        expect(response.status).to be 200
      end
    end
  end

  describe 'DELETE /api/v1/groups/:string_key' do
    context 'when deleting a group that exists' do
      let(:string_key) { 'administrators' }

      before do
        FactoryBot.create(:group, string_key: string_key)
        delete "/api/v1/groups/#{string_key}"
      end

      it 'returns 204' do
        expect(response.status).to be 204
      end

      it 'deletes record from database' do
        expect(Group.find_by(string_key: string_key)).to be nil
      end
    end

    context 'when deleting a group that does not exist' do
      before { delete '/api/v1/groups/not-valid' }

      it 'returns errors' do
        expect(response.body).to be_json_eql(%(
          { "errors": [ { "title": "Not Found" } ] }
        ))
      end

      it 'returns 404' do
        expect(response.status).to be 404
      end
    end
  end
end
