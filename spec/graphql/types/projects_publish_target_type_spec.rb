# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Types::ProjectsPublishTargetType do
  let(:graphql_request) { HyacinthSchema.execute(query, context: context) }
  let(:current_user) { FactoryBot.create(:user) }
  let(:ability) { instance_double(Ability) }
  let(:model_adapter) { instance_double(CanCan::ModelAdapters::ActiveRecordAdapter) }
  let(:context) { { current_user: current_user, ability: ability } }

  context 'when user is authorized' do
    include_context 'with stubbed search adapters'
    let(:project) { FactoryBot.create(:project, :legend_of_lincoln, :with_publish_target) }
    let!(:original_publish_targets) { project.publish_targets.map { |pt| { 'stringKey' => pt.string_key } } }
    let!(:additional_publish_target) { FactoryBot.create(:publish_target) }
    let(:query) do
      <<~GQL
        query {
          projectsPublishTargets(project: { stringKey: "#{project.string_key}" }) {
            stringKey
            enabled
          }
        }
      GQL
    end
    let(:errors) { graphql_request.to_h.dig('errors') }
    let(:publish_targets) { graphql_request.to_h.dig('data', 'projectsPublishTargets') }
    let(:enabled_publish_target) { publish_targets.detect { |pt| pt['enabled'] } }
    let(:non_enabled_publish_target) { publish_targets.detect { |pt| !pt['enabled'] } }
    before do
      # skipping authorization because it's not part of what we're testing
      allow(ability).to receive(:authorize!)
      expect(ability).to receive(:model_adapter).and_return(model_adapter)
      allow(model_adapter).to receive(:database_records).and_return(PublishTarget.all)
    end
    it 'returns list of all publish targets, with enabled property set to true if project has enabled' do
      expect(original_publish_targets).to include('stringKey' => enabled_publish_target&.fetch('stringKey'))
      expect(additional_publish_target.string_key).to eql(non_enabled_publish_target&.fetch('stringKey'))
    end
  end
end
