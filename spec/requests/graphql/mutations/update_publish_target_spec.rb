require 'rails_helper'

RSpec.describe Mutations::UpdatePublishTarget, type: :request do
  let(:project) { FactoryBot.create(:project) }
  let(:publish_target) { FactoryBot.create(:publish_target, project: project) }

  include_examples 'requires user to have correct permissions for graphql request' do
    let(:variables) do
      { input: { projectStringKey: project.string_key, stringKey: publish_target.string_key } }
    end
    let(:request) { graphql query, variables }
  end

  context 'when logged in user has correct permissions' do
    before { sign_in_user as: :administrator }

    context 'when updating record' do
      let(:variables) do
        {
          input: {
            projectStringKey: project.string_key,
            stringKey: publish_target.string_key,
            displayLabel: 'Bestest Project',
            publishUrl: 'https://best_project.com/publish'
          }
        }
      end

      before { graphql query, variables }
      
      it 'correctly updates record' do
        publish_target.reload
        expect(publish_target.display_label).to eql 'Bestest Project'
        expect(publish_target.publish_url).to eql 'https://best_project.com/publish'
      end
    end
  end

  def query
    <<~GQL
      mutation ($input: UpdatePublishTargetInput!) {
        updatePublishTarget(input: $input) {
          publishTarget {
            stringKey
            displayLabel
          }
        }
      }
    GQL
  end
end
