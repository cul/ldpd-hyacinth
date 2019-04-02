require 'rails_helper'

RSpec.describe 'Dynamic Field Groups Requests', type: :request do
  describe 'GET /api/v1/dynamic_field_groups/:id' do
    let(:dynamic_field_group) { FactoryBot.create(:dynamic_field_group) }

    include_examples 'requires user to have correct permissions' do
      let(:request) { get "/api/v1/dynamic_field_groups/#{dynamic_field_group.id}" }
    end

    context 'when logged in user is an administrator' do
      before { sign_in_user as: :administrator }

      context 'when id is valid' do
        before do
          get "/api/v1/dynamic_field_groups/#{dynamic_field_group.id}"
        end

        it 'returns 200' do
          expect(response.status).to be 200
        end

        it 'returns correct response' do
          expect(response.body).to be_json_eql(%(
            {
              "dynamic_field_group": {
                "children": [],
                "display_label": "Name",
                "is_repeatable": true,
                "sort_order": 3,
                "string_key": "name",
                "type": "DynamicFieldGroup",
                "xml_translation": "[\\n\\n]"
              }
            }
          ))
        end
      end

      context 'when id is invalid' do
        before do
          get '/api/v1/dynamic_field_groups/1234'
        end

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
  end

  describe 'POST /api/v1/dynamic_field_groups' do
    include_examples 'requires user to have correct permissions' do
      let(:request) do
        post '/api/v1/dynamic_field_groups', params: { dynamic_field_group: { string_key: 'location' } }
      end
    end

    context 'when logged in user is an administrator' do
      let(:parent) { FactoryBot.create(:dynamic_field_category) }
      before { sign_in_user as: :administrator }

      context 'when creating a new dynamic field group' do
        before do
          post '/api/v1/dynamic_field_groups', params: {
            dynamic_field_group: {
              string_key: 'location', display_label: 'Location', sort_order: '8',
              is_repeatable: true, parent_type: parent.class.to_s, parent_id: parent.id
            }
          }
        end

        it 'returns 201' do
          expect(response.status).to be 201
        end

        it 'returns correct response' do
          expect(response.body).to be_json_eql(%(
            {
              "dynamic_field_group": {
                "children": [],
                "display_label": "Location",
                "is_repeatable": true,
                "sort_order": 8,
                "string_key": "location",
                "type": "DynamicFieldGroup",
                "xml_translation": "[\\n\\n]"
              }
            }
          ))
        end

        it 'adds child to parent' do
          parent.reload
          expect(parent.children.length).to be 1
        end
      end

      context 'when creating without a string_key' do
        before do
          post '/api/v1/dynamic_field_groups', params: {
            dynamic_field_group: {
              display_label: 'Location', sort_order: '8',
              is_repeatable: true, parent_type: parent.class.to_s, parent_id: parent.id
            }
          }
        end

        it 'returns 422' do
          expect(response.status).to be 422
        end

        it 'returns errors' do
          expect(response.body).to be_json_eql(%(
            {
              "errors": [
                { "title": "String key can't be blank" }
              ]
            }
          ))
        end
      end
    end
  end

  describe 'PATCH /api/v1/dynamic_field_groups/:id' do
    let(:dynamic_field_group) { FactoryBot.create(:dynamic_field_group) }

    include_examples 'requires user to have correct permissions' do
      let(:request) do
        patch "/api/v1/dynamic_field_groups/#{dynamic_field_group.id}", params: { dynamic_field_group: {} }
      end
    end

    context 'when logged in user is an administator' do
      before { sign_in_user as: :administrator }

      context 'when updating display_label' do
        before do
          patch "/api/v1/dynamic_field_groups/#{dynamic_field_group.id}", params: { dynamic_field_group: { display_label: 'New Location' } }
        end

        it 'returns 200' do
          expect(response.status).to be 200
        end

        it 'correctly updates record' do
          dynamic_field_group.reload
          expect(dynamic_field_group.display_label).to eql 'New Location'
        end
      end

      context 'when updating to incorrect parent type' do
        before do
          patch "/api/v1/dynamic_field_groups/#{dynamic_field_group.id}", params: { dynamic_field_group: { parent_type: 'User' } }
        end

        it 'returns 422' do
          expect(response.status).to be 422
        end

        it 'returms errors' do
          expect(response.body).to be_json_eql(%(
            {
              "errors": [
                { "title": "Parent type is not among the list of allowed values" }
              ]
            }
          ))
        end
      end
    end
  end

  describe 'DELETE /api/v1/dynamic_field_groups/:id' do
    let(:dynamic_field_group) { FactoryBot.create(:dynamic_field_group) }

    include_examples 'requires user to have correct permissions' do
      let(:request) do
        delete "/api/v1/dynamic_field_groups/#{dynamic_field_group.id}"
      end
    end

    context 'when logged in user is an administrator' do
      before { sign_in_user as: :administrator }

      context 'when deleting a dynamic_field_group that exists' do
        let(:id) { dynamic_field_group.id }

        before do
          delete "/api/v1/dynamic_field_groups/#{id}"
        end

        it 'returns 204' do
          expect(response.status).to be 204
        end

        it 'deletes record from database' do
          expect(DynamicFieldGroup.find_by(id: id)).to be nil
        end
      end

      context 'when deleting a dynamic_field_group that does not exist' do
        before { delete '/api/v1/dynamic_field_groups/123' }

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
end
