# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::UpdateProjectEnabledFields, type: :request do
  let(:project) { FactoryBot.create(:project) }
  let(:field_set) { FactoryBot.create(:field_set, project: project) }
  let(:dynamic_field_category) { FactoryBot.create(:dynamic_field_category, display_label: "UpdateProjectEnabledFields") }
  let(:dynamic_field_group) { FactoryBot.create(:dynamic_field_group, parent: dynamic_field_category) }
  let(:previous_dynamic_field) { FactoryBot.create(:dynamic_field, string_key: "former_field", dynamic_field_group: dynamic_field_group) }
  let(:added_dynamic_field) { FactoryBot.create(:dynamic_field, string_key: "next_field", dynamic_field_group: dynamic_field_group) }
  let(:default_value) { "exampleDefaultValue" }
  let(:previously_enabled_dynamic_field) { FactoryBot.create(:enabled_dynamic_field, project: project, dynamic_field: previous_dynamic_field, required: false, default_value: default_value) }
  let(:enabled_dynamic_fields) do
    [
      {
        dynamicField: { id: added_dynamic_field.id },
        fieldSets: [{ id: field_set.id }],
        required: false,
        hidden: false,
        locked: false,
        ownerOnly: false,
        shareable: true
      }
    ]
  end
  let(:variables) do
    {
      input: {
        project: {
          stringKey: project.string_key
        },
        digitalObjectType: 'item',
        enabledDynamicFields: enabled_dynamic_fields
      }
    }
  end

  include_examples 'requires user to have correct permissions for graphql request' do
    let(:request) { graphql query, variables }
  end

  context 'when logged in user is project manager' do
    before do
      sign_in_project_contributor to: :manage, project: project
    end

    context 'when updating enabled dynamic fields' do
      before do
        previous_dynamic_field
        graphql query, variables
      end
      context 'with an empty array' do
        let(:enabled_dynamic_fields) { [] }
        it 'enables no dynamic fields' do
          results = EnabledDynamicField.where(
            project_id: project.id, digital_object_type: 'item'
          ).to_a
          expect(results.length).to be 0
        end
      end
      context 'with a replacement dynamic field' do
        it 'enables the expected dynamic fields' do
          results = EnabledDynamicField.where(
            project_id: project.id, digital_object_type: 'item'
          ).to_a
          expect(results.length).to be 1
          expect(results.first.dynamic_field_id).to be added_dynamic_field.id
        end
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
            }
            digitalObjectType
            required
            locked
            hidden
            ownerOnly
            defaultValue
            shareable
          }
        }
      }
    GQL
  end
end
