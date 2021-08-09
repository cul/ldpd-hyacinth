# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::DigitalObject::Resource::DeleteResource, solr: true do
  subject(:graphql_request) { HyacinthSchema.execute(query, context: context, variables: variables) }
  let(:context) { { current_user: FactoryBot.create(:user), ability: ability } }

  context 'when digital object is an Asset' do
    let(:digital_object) { FactoryBot.create(:asset, :with_main_resource, :with_access_resource) }
    let(:variables) { { input: { id: digital_object.uid, resourceName: 'access' } } }
    let(:ability) do
      abil = double
      # skipping authorization because it's not part of what we're testing
      allow(abil).to receive(:authorize!)
      abil
    end
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
      allow(ability.authorize!)
    end

    # TODO: Need to update to the way that digital objects save, since deep_clone method
    # (which uses Marshal.dump) isn't compatible with rspec mocks.
    it 'sets the flag to skip resource request callbacks (to avoid regenerating the just-deleted resource)' do
      # TODO: Use commented out code instead when DigitalObject#save method works with rspec mocks
      # expect(digital_object).to receive(:skip_resource_request_callbacks=).with(true)
      # TODO: Replace line below with line above
      expect(ResourceRequests::AccessJob).not_to receive(:perform_later_if_eligible)

      graphql_request
    end
  end
end
