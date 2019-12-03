# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Dynamic Field Groups Requests', type: :request do
  let!(:field_export_profile) { FactoryBot.create(:field_export_profile) }

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
                "parent_type": "DynamicFieldCategory",
                "children": [],
                "display_label": "Name",
                "is_repeatable": true,
                "sort_order": 3,
                "string_key": "name",
                "type": "DynamicFieldGroup",
                "export_rules": []
              }
            }
          )).excluding('parent_id')
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
              is_repeatable: true, parent_type: parent.class.to_s, parent_id: parent.id,
              export_rules: [{ field_export_profile_id: field_export_profile.id }]
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
                "parent_type": "DynamicFieldCategory",
                "children": [],
                "display_label": "Location",
                "is_repeatable": true,
                "sort_order": 8,
                "string_key": "location",
                "type": "DynamicFieldGroup",
                "export_rules": [ { "translation_logic": "[\\n\\n]", "field_export_profile_id": #{field_export_profile.id} }]
              }
            }
          )).excluding('parent_id')
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

        it 'returns 400' do
          expect(response.status).to be 400
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
    let!(:dynamic_field_group) { FactoryBot.create(:dynamic_field_group) }
    let!(:export_rule) do
      FactoryBot.create(
        :export_rule,
        dynamic_field_group: dynamic_field_group,
        field_export_profile: field_export_profile
      )
    end

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

        it 'does not update export_rules' do
          dynamic_field_group.reload
          expect(dynamic_field_group.export_rules).to match_array [export_rule]
        end
      end

      context 'when updating to incorrect parent type' do
        before do
          patch "/api/v1/dynamic_field_groups/#{dynamic_field_group.id}", params: { dynamic_field_group: { parent_type: 'User' } }
        end

        it 'returns 400' do
          expect(response.status).to be 400
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

      context 'when updating export_rules' do
        before do
          patch "/api/v1/dynamic_field_groups/#{dynamic_field_group.id}", params: {
            dynamic_field_group: { export_rules: [{ id: export_rule.id, translation_logic: "[{}, {}]" }] }
          }
        end

        it 'returns 200' do
          expect(response.status).to be 200
        end

        it 'updates export_rule' do
          export_rule.reload
          expect(export_rule.translation_logic).to be_json_eql "[{}, {}]"
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
