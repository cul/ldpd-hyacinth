# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::DigitalObject::Resource::DeleteResource do
  let(:graphql_request) { HyacinthSchema.execute(query, context: context, variables: variables) }
  let(:context) { { current_user: FactoryBot.create(:user), ability: ability } }

  context 'when digital object is an Asset' do
    include_context 'with stubbed search adapters'
    let(:digital_object) { FactoryBot.create(:asset, :with_main_resource, :with_access_resource) }
    let(:variables) { { input: { id: digital_object.uid, resourceName: 'access' } } }
    let(:ability) { instance_double(Ability) }
    let(:query) do
      <<~GQL
        mutation ($input: DeleteResourceInput!) {
          deleteResource(input: $input) {
            digitalObject {
              id
            }
          }
        }
      GQL
    end

    before do
      allow(::DigitalObject).to receive(:find_by_uid!).and_return(digital_object)
      # skipping authorization because it's not part of what we're testing
      allow(ability).to receive(:authorize!)
    end

    it 'sets the flag to skip resource request callbacks (to avoid regenerating the just-deleted resource)' do
      expect(digital_object).to receive(:skip_resource_request_callbacks=).with(true).and_call_original
      expect(ResourceRequests::AccessJob).not_to receive(:perform_later_if_eligible)

      graphql_request
    end
  end
end
