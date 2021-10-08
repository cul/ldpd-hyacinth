# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::FieldSet::UpdateFieldSet, type: :request do
  let(:project) { FactoryBot.create(:project) }
  let(:field_set) { FactoryBot.create(:field_set, project: project) }

  include_examples 'a basic user with no abilities is not authorized to perform this request' do
    let(:variables) do
      {
        input: {
          projectStringKey: project.string_key,
          id: field_set.id
        }
      }
    end
    let(:request) { graphql query, variables }
  end

  context 'when logged in user is project manager' do
    before { sign_in_project_contributor actions: :manage, projects: project }

    context 'when updating record' do
      let(:variables) do
        {
          input: {
            projectStringKey: project.string_key,
            id: field_set.id,
            displayLabel: 'Monograph Part'
          }
        }
      end
      before { graphql query, variables }

      it 'correctly updates record' do
        field_set.reload
        expect(field_set.display_label).to eql 'Monograph Part'
      end
    end

    context 'when updating record with invalid display_label' do
      let(:variables) do
        {
          input: {
            projectStringKey: project.string_key,
            id: field_set.id,
            displayLabel: nil
          }
        }
      end

      before { graphql query, variables }

      it 'returns error' do
        expect(response.body).to be_json_eql(%(
          "Display label can't be blank"
        )).at_path('errors/0/message')
      end
    end
  end

  def query
    <<~GQL
      mutation ($input: UpdateFieldSetInput!) {
        updateFieldSet(input: $input) {
          fieldSet {
            id
            displayLabel
          }
        }
      }
    GQL
  end
end
