# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::DigitalObject::PublishDigitalObject, type: :request do
  include_context 'with stubbed search adapters'

  let(:project) { FactoryBot.create(:project) }
  let(:authorized_object) { FactoryBot.create(:item, primary_project: project) }
  let(:publish_to) { [FactoryBot.create(:publish_target).string_key] }
  let(:unpublish_from) { [] }
  let(:response_object) { JSON.parse(response.body) }
  let(:variables) { { input: { id: authorized_object.uid, publishTo: publish_to, unpublishFrom: unpublish_from } } }

  include_examples 'a basic user with no abilities is not authorized to perform this request' do
    let(:request) { graphql query, variables }
  end

  context "when logged in user has appropriate permissions" do
    before do
      sign_in_project_contributor actions: :publish_objects, projects: project
    end

    context "and the digital object has been preserved" do
      before do
        authorized_object.preserve
      end

      context "with publish targets supplied in publish_to" do
        let(:publish_targets_to_add) do
          [
            FactoryBot.create(:publish_target),
            FactoryBot.create(:publish_target)
          ]
        end
        let(:publish_to) { publish_targets_to_add.map(&:string_key) }
        let(:expected_response) do
          %({
            "digitalObject": {
              "id": "#{authorized_object.uid}",
              "publishEntries": [
                { "publishTarget": { "stringKey": "#{publish_targets_to_add[0].string_key}" } },
                { "publishTarget": { "stringKey": "#{publish_targets_to_add[1].string_key}" } }
              ]
            },
            "userErrors": []
          })
        end

        before { graphql query, variables }

        it "adds the publish targets and returns the expected response" do
          expect(response.body).to be_json_eql(expected_response).at_path('data/publishDigitalObject')
        end
      end

      context "with publish targets supplied in unpublish_from" do
        let(:publish_targets_to_remove) do
          [
            FactoryBot.create(:publish_target),
            FactoryBot.create(:publish_target)
          ]
        end
        let(:publish_to) { [] }
        let(:unpublish_from) { publish_targets_to_remove.map(&:string_key) }

        before do
          expect(authorized_object.publish_entries.length).to eq(0)
          # Publish to the targets first so that the mutation can remove them later
          expect(authorized_object.perform_publish_changes(publish_to: publish_targets_to_remove)).to eq(true)
          expect(authorized_object.publish_entries.length).to eq(publish_targets_to_remove.length)
          graphql query, variables
        end

        it "removes the publish entries and returns the expected response" do
          expect(response.body).to be_json_eql(%({
            "digitalObject": {
              "id": "#{authorized_object.uid}",
              "publishEntries": []
            },
            "userErrors": []
          })).at_path('data/publishDigitalObject')
        end
      end
    end

    context "and the digital object has NOT been preserved" do
      before do
        graphql query, variables
      end

      it "returns the expected error" do
        expect(response.body).to be_json_eql(%({
          "digitalObject": null,
          "userErrors": [{
            "message": "Cannot publish a DigitalObject that has not been preserved",
            "path": ["publish"]
          }]
        })).at_path('data/publishDigitalObject')
      end
    end
  end

  def query
    <<~GQL
      mutation PublishDigitalObject($input: PublishDigitalObjectInput!) {
        publishDigitalObject(input: $input) {
          digitalObject {
            id
            publishEntries {
              publishTarget {
                stringKey
              }
            }
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
