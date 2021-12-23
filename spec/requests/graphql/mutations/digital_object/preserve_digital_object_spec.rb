# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::DigitalObject::PreserveDigitalObject, type: :request do
  include_context 'with stubbed search adapters'

  let(:project) { FactoryBot.create(:project) }
  let(:authorized_object) { FactoryBot.create(:item, primary_project: project) }

  include_examples 'a basic user with no abilities is not authorized to perform this request' do
    let(:variables) { { input: { id: authorized_object.uid } } }
    let(:request) { graphql query, variables }
  end

  context "when logged in user has appropriate permissions" do
    let(:variables) { { input: { id: authorized_object.uid } } }
    let!(:original_object_preservation_time) { authorized_object.preserved_at }
    let(:response_object) { JSON.parse(response.body) }

    before do
      sign_in_project_contributor actions: :publish_objects, projects: project
      graphql query, variables
    end

    it "returns the expected response" do
      expect(response_object.dig('data', 'preserveDigitalObject', 'userErrors')).to be_blank
      expect(response_object.dig('data', 'preserveDigitalObject', 'digitalObject', 'id')).to eq(authorized_object.uid)
      expect(response_object.dig('data', 'preserveDigitalObject', 'digitalObject', 'preservedAt')).not_to eq(original_object_preservation_time)
    end
  end

  def query
    <<~GQL
      mutation PreserveDigitalObject($input: PreserveDigitalObjectInput!) {
        preserveDigitalObject(input: $input) {
          digitalObject {
            id
            preservedAt
          }
          userErrors {
            message
            path
          }
        }
      }
    GQL
  end
end
