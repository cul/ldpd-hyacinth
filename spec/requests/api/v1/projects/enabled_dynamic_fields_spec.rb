require 'rails_helper'

RSpec.describe 'Enabled Dynamic Fields Requests', type: :request do
  let(:project) { FactoryBot.create(:project) }

  describe 'GET /api/v1/projects/:string_key/enabled_dynamic_fields/:digital_object_type' do
    before do
      enabled_dynamic_field = FactoryBot.create(:enabled_dynamic_field, project: project)
      new_dynamic_field = FactoryBot.create(
        :dynamic_field,
        string_key: 'name',
        dynamic_field_group: enabled_dynamic_field.dynamic_field.dynamic_field_group
      )
      FactoryBot.create(:enabled_dynamic_field, project: project, dynamic_field: new_dynamic_field)
    end

    context 'when querying for all item enabled dynamic fields' do
      before do
        get "/api/v1/projects/#{project.string_key}/enabled_dynamic_fields/item"
      end

      it 'returns 200' do
        expect(response.status).to be 200
      end

      it 'returns all expected results' do
        expect(response.body).to be_json_eql(%(
          {
            "enabled_dynamic_fields": [
              {
                "default_value": null,
                "dynamic_field_id": 1,
                "hidden": false,
                "locked": false,
                "owner_only": false,
                "required": true
              },
              {
                "default_value": null,
                "dynamic_field_id": 2,
                "hidden": false,
                "locked": false,
                "owner_only": false,
                "required": true
              }
            ]
          }
        ))
      end
    end
  end

  describe 'PATCH /api/v1/projects/:string_key/enabled_dynamic_fields/:digital_object_type' do
    let(:enabled_dynamic_field) { FactoryBot.create(:enabled_dynamic_field, project: project) }

    context 'when updating an enabled dynamic field' do
      before do
        patch "/api/v1/projects/#{project.string_key}/enabled_dynamic_fields/item", params: {
          enabled_dynamic_fields: [{ id: enabled_dynamic_field.id, locked: true, owner_only: true }]
        }
      end

      it 'returns 200' do
        expect(response.status).to be 200
      end

      it 'correctly updates record' do
        enabled_dynamic_field.reload
        expect(enabled_dynamic_field.locked).to be true
        expect(enabled_dynamic_field.owner_only).to be true
        expect(enabled_dynamic_field.digital_object_type).to eq 'item'
      end
    end

    context 'when trying to change digital_object_type' do
      before do
        patch "/api/v1/projects/#{project.string_key}/enabled_dynamic_fields/item", params: {
          enabled_dynamic_fields: [{ id: enabled_dynamic_field.id, digital_object_type: 'asset' }]
        }
      end

      it 'returns 200' do
        expect(response.status).to be 200
      end

      it 'does not change digital_object_type' do
        enabled_dynamic_field.reload
        expect(enabled_dynamic_field.digital_object_type).to eq 'item'
      end
    end

    context 'when updating multiple enabled_dynamic_fields' do
      let(:new_dynamic_field) do
        FactoryBot.create(
          :dynamic_field,
          string_key: 'name',
          dynamic_field_group: enabled_dynamic_field.dynamic_field.dynamic_field_group
        )
      end

      let(:enabled_dynamic_field_2) do
        FactoryBot.create(:enabled_dynamic_field, project: project, dynamic_field: new_dynamic_field)
      end

      before do
        enabled_dynamic_field_2
        patch "/api/v1/projects/#{project.string_key}/enabled_dynamic_fields/item", params: {
          enabled_dynamic_fields: [
            { id: enabled_dynamic_field.id, owner_only: true },
            { id: enabled_dynamic_field_2.id, required: false }
          ]
        }
      end

      it 'returns 200' do
        expect(response.status).to be 200
      end

      it 'update first dynamic field' do
        enabled_dynamic_field.reload
        expect(enabled_dynamic_field.required).to be true
        expect(enabled_dynamic_field.owner_only).to be true
      end

      it 'updates second dynamic field' do
        enabled_dynamic_field_2.reload
        expect(enabled_dynamic_field_2.required).to be false
        expect(enabled_dynamic_field_2.owner_only).to be false
      end
    end
  end
end
