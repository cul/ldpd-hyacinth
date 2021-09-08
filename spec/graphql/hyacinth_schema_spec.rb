# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HyacinthSchema do
  let(:graphql_request) { described_class.execute(query, context: context, variables: variables) }
  let(:context) { { current_user: FactoryBot.create(:user), ability: ability } }
  let(:ability) { instance_double(Ability) }
  let(:graphql_response_as_hash) { graphql_request.to_h }

  describe 'schema-level error rescue' do
    include_context 'with stubbed search adapters'
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
      let(:query_class) { Mutations::DigitalObject::UpdateDescriptiveMetadata }
      let(:error_class) { Hyacinth::Exceptions::HyacinthError }
      let(:error_message) { 'This is the error' }
      before do
        allow_any_instance_of(query_class).to receive(:resolve).and_raise(error_class, error_message)
        # skipping authorization because it's not part of what we're testing
        allow(ability).to receive(:authorize!)
      end
      it 'is rescued and the error is placed in the top level graphql response "errors" field with message and path' do
        expect(graphql_response_as_hash.dig('errors', 0, 'message')).to eq(error_message)
        expect(graphql_response_as_hash.dig('errors', 0, 'path')).to eq(['updateDescriptiveMetadata'])
      end
    end
  end
end
