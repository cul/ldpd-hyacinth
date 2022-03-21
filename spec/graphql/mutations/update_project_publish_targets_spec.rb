# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::UpdateProjectPublishTargets do
  let(:graphql_request) { HyacinthSchema.execute(query, context: context, variables: variables) }
  let(:context) { { current_user: FactoryBot.create(:user), ability: ability } }
  let(:ability) { instance_double(Ability) }

  context 'when user is authorized' do
    include_context 'with stubbed search adapters'
    let(:project) { FactoryBot.create(:project, :legend_of_lincoln, :with_publish_target) }
    let!(:original_publish_targets) { project.publish_targets.map { |pt| { 'stringKey' => pt.string_key } } }
    let(:additional_publish_target) { FactoryBot.create(:publish_target) }
    let(:variables) { { input: { project: { stringKey: project.string_key }, publishTargets: publish_targets } } }
    let(:query) do
      <<~GQL
        mutation ($input: UpdateProjectPublishTargetsInput!) {
          updateProjectPublishTargets(input: $input) {
            enabledPublishTargets {
              stringKey
            }
          }
        }
      GQL
    end
    let(:errors) { graphql_request.to_h['errors'] }
    let(:resolved_publish_targets) { graphql_request.to_h.dig('data', 'updateProjectPublishTargets', 'enabledPublishTargets') }
    let(:resolved_publish_target_ids) { resolved_publish_targets.map { |pt| pt['stringKey'] } }
    before do
      # skipping authorization because it's not part of what we're testing
      allow(ability).to receive(:authorize!)
    end
    context 'input is an empty array' do
      let(:publish_targets) { [] }
      it 'deletes the join entities, but not the publish targets' do
        expect(errors).to be_blank
        expect(resolved_publish_targets).to be_empty
      end
    end
    context 'input is an unchanged array' do
      let(:publish_targets) { original_publish_targets }
      it 'makes no changes' do
        expect(resolved_publish_targets).to eql(original_publish_targets)
      end
    end
    context 'input is an array including original targets' do
      let(:publish_targets) { original_publish_targets + [{ 'stringKey' => additional_publish_target.string_key }] }
      it 'adds join entities for the addtional targets, preserving existing publish targets' do
        expect(resolved_publish_targets).to include(*original_publish_targets)
        expect(resolved_publish_targets.length).to be > original_publish_targets.length
      end
    end
    context 'input is an array disjoint from original targets' do
      let(:publish_targets) { [{ 'stringKey' => additional_publish_target.string_key }] }
      it 'adds join entities for the addtional targets, preserving existing publish targets' do
        expect(resolved_publish_targets).not_to include(*original_publish_targets)
      end
    end
  end
end
