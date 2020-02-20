# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::FieldSet::CreateFieldSet, type: :request do
  let(:project) { FactoryBot.create(:project) }

  include_examples 'requires user to have correct permissions for graphql request' do
    let(:variables) { { input: { projectStringKey: project.string_key, displayLabel: 'Monograph Part' } } }
    let(:request) { graphql query, variables }
  end

  context 'when logged in user is project manager' do
    before { sign_in_project_contributor to: :manage, project: project }

    context 'when creating a new field set' do
      let(:variables) do
        {
          input: {
            projectStringKey: project.string_key,
            displayLabel: 'Monograph Part'
          }
        }
      end

      before { graphql query, variables }

      it 'returns correct response' do
        expect(response.body).to be_json_eql(%({
          "fieldSet": { "displayLabel": "Monograph Part" }
        })).at_path('data/createFieldSet')
      end
    end

    context 'when create request is missing display_label' do
      let(:variables) { { input: { projectStringKey: project.string_key } } }

      before { graphql query, variables }

      it 'returns error' do
        expect(response.body).to be_json_eql(%(
           "Variable input of type CreateFieldSetInput! was provided invalid value for displayLabel (Expected value to not be null)"
        )).at_path('errors/0/message')
      end
    end
  end

  def query
    <<~GQL
      mutation ($input: CreateFieldSetInput!) {
        createFieldSet(input: $input) {
          fieldSet {
            id
            displayLabel
          }
        }
      }
    GQL
  end
end
