# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::UpdateProjectEnabledFields, type: :request do
  let(:project) { FactoryBot.create(:project) }
  let(:field_set) { FactoryBot.create(:field_set, project: project) }
  let(:dynamic_field_category) { FactoryBot.create(:dynamic_field_category, display_label: "UpdateProjectEnabledFields") }
  let(:dynamic_field_group) { FactoryBot.create(:dynamic_field_group, parent: dynamic_field_category) }
  let(:dynamic_field) { FactoryBot.create(:dynamic_field, string_key: "dynamic_field", dynamic_field_group: dynamic_field_group) }
  let(:digital_object_type) { 'item' }
  let(:default_value) { "exampleDefaultValue" }
  let(:enabled_dynamic_field_input_values) do
    [
      {
        dynamicField: { id: dynamic_field.id },
        fieldSets: [{ id: field_set.id }],
        required: true,
        shareable: true,
        defaultValue: default_value,
        hidden: false,
        locked: false,
        ownerOnly: false
      }
    ]
  end
  let(:variables) do
    {
      input: {
        project: {
          stringKey: project.string_key
        },
        digitalObjectType: digital_object_type.upcase,
        enabledDynamicFields: enabled_dynamic_field_input_values
      }
    }
  end

  include_examples 'a basic user with no abilities is not authorized to perform this request' do
    let(:request) { graphql query, variables }
  end

  context 'when logged in user is project manager' do
    let(:already_enabled_field) { nil }
    let(:field_is_used_by_project) { false }

    before do
      sign_in_project_contributor actions: :manage, projects: project
      already_enabled_field
      allow(Hyacinth::Config.digital_object_search_adapter).to receive(:field_used_in_project?).and_return field_is_used_by_project
      graphql query, variables
    end

    context 'enabling a dynamic field that is not enabled' do
      it 'enables the expected dynamic field with the expected values' do
        results = EnabledDynamicField.where(
          project_id: project.id, digital_object_type: digital_object_type
        ).to_a
        expect(results.length).to be 1
        results.first.tap do |edf|
          expect(edf.required).to eq(true)
          expect(edf.shareable).to eq(true)
          expect(edf.default_value).to eq(default_value)
          expect(edf.dynamic_field.id).to eq(dynamic_field.id)
        end
      end
      it 'returns the expected response' do
        expect(response.body).to be_json_eql(%(
          [
            {
              "defaultValue": "exampleDefaultValue",
              "digitalObjectType": "ITEM",
              "dynamicField": {
              },
              "fieldSets": [{
                "id": #{field_set.id},
                "displayLabel": "#{field_set.display_label}"
              }],
              "hidden": false,
              "locked": false,
              "ownerOnly": false,
              "project": {
                "stringKey": "great_project"
              },
              "required": true,
              "shareable": true
            }
          ]
        )).at_path('data/updateProjectEnabledFields/projectEnabledFields')
      end
    end

    context 'updating a dynamic field that is already enabled' do
      let(:already_enabled_field) { EnabledDynamicField.create!(dynamic_field: dynamic_field, project: project, digital_object_type: digital_object_type) }

      it 'updates the expected enabled dynamic field' do
        results = EnabledDynamicField.where(
          project_id: project.id, digital_object_type: digital_object_type
        ).to_a
        expect(results.length).to be 1
        results.first.tap do |edf|
          expect(edf.id).to eq(already_enabled_field.id) # we expect an update to the existing edf, so id stays the same
          expect(edf.required).to eq(true)
          expect(edf.shareable).to eq(true)
          expect(edf.default_value).to eq(default_value)
          expect(edf.dynamic_field.id).to eq(dynamic_field.id)
        end
      end
      it 'returns the expected response' do
        expect(response.body).to be_json_eql(%(
          [
            {
              "defaultValue": "exampleDefaultValue",
              "digitalObjectType": "ITEM",
              "dynamicField": {
              },
              "fieldSets": [{
                "id": #{field_set.id},
                "displayLabel": "#{field_set.display_label}"
              }],
              "hidden": false,
              "locked": false,
              "ownerOnly": false,
              "project": {
                "stringKey": "great_project"
              },
              "required": true,
              "shareable": true
            }
          ]
        )).at_path('data/updateProjectEnabledFields/projectEnabledFields')
      end
    end

    context 'disabling all dynamic fields' do
      let(:already_enabled_field) { FactoryBot.create(:enabled_dynamic_field, dynamic_field: dynamic_field, project: project, digital_object_type: digital_object_type, field_sets: [field_set]) }
      let(:enabled_dynamic_field_input_values) { [] }
      it 'disables all dynamic fields' do
        results = EnabledDynamicField.where(
          project_id: project.id, digital_object_type: digital_object_type.upcase
        ).to_a
        expect(results.length).to be 0
      end
      it 'returns the expected response' do
        expect(response.body).to be_json_eql(%([])).at_path('data/updateProjectEnabledFields/projectEnabledFields')
      end
    end

    context "disabling a dynamic field that's in use by the project" do
      let(:already_enabled_field) { FactoryBot.create(:enabled_dynamic_field, dynamic_field: dynamic_field, project: project, digital_object_type: digital_object_type, field_sets: [field_set]) }
      let(:enabled_dynamic_field_input_values) { [] }
      let(:field_is_used_by_project) { true }
      it 'returns the expected response, with error message and field still enabled' do
        expect(response.body).to be_json_eql(%(
          "Cannot disable #{dynamic_field.display_label} because it's used by one or more #{digital_object_type.pluralize} in #{project.display_label}"
        )).at_path('data/updateProjectEnabledFields/userErrors/0/message')
        expect(response.body).to be_json_eql(%(
          [
            {
              "defaultValue": null,
              "digitalObjectType": "ITEM",
              "dynamicField": {
              },
              "fieldSets": [{
                "id": #{field_set.id},
                "displayLabel": "#{field_set.display_label}"
              }],
              "hidden": false,
              "locked": false,
              "ownerOnly": false,
              "project": {
                "stringKey": "great_project"
              },
              "required": true,
              "shareable": false
            }
          ]
        )).at_path('data/updateProjectEnabledFields/projectEnabledFields')
      end
    end
  end

  def query
    <<~GQL
      mutation ($input: UpdateProjectEnabledFieldsInput!) {
        updateProjectEnabledFields(input: $input) {
          projectEnabledFields {
            dynamicField {
              id
            }
            project {
              stringKey
            }
            fieldSets {
              id
              displayLabel
            }
            digitalObjectType
            required
            locked
            hidden
            ownerOnly
            defaultValue
            shareable
          }
          userErrors {
            message
            path
          }
        }
      }
    GQL
  end
end
