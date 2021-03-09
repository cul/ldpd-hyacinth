# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HyacinthSchema, solr: true do
  subject(:graphql_request) { HyacinthSchema.execute(query, context: context, variables: variables) }
  let(:context) { { current_user: FactoryBot.create(:user), ability: ability } }
  let(:ability) do
    abil = double
    # skipping authorization because it's not part of what we're testing
    allow(abil).to receive(:authorize!)
    abil
  end
  let(:graphql_response_as_hash) { graphql_request.to_h }

  describe 'schema-level error rescue' do
    let(:digital_object) { FactoryBot.create(:item) }
    let(:query) do
      <<~GQL
        mutation ($input: UpdateDescriptiveMetadataInput!) {
          updateDescriptiveMetadata(input: $input) {
            digitalObject {
              id
              descriptiveMetadata
            }
          }
        }
      GQL
    end
    let(:variables) { { input: { id: digital_object.uid, descriptiveMetadata: { title: [{ non_sort_portion: "The", sort_portion: "Text Here Does Not Matter" }] } } } }

    context "when a Hyacinth::Exceptions::HyacinthError is raised during a query" do
      before { allow_any_instance_of(Mutations::DigitalObject::UpdateDescriptiveMetadata).to receive(:resolve).and_raise(Hyacinth::Exceptions::HyacinthError, 'This is the error') }
      it 'is rescued and the error is placed in the top level graphql response "errors" field with message and path' do
        expect(graphql_response_as_hash.dig('errors', 0, 'message')).to eq('This is the error')
        expect(graphql_response_as_hash.dig('errors', 0, 'path')).to eq(['updateDescriptiveMetadata'])
      end
    end
  end
end
