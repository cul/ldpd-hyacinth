# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::DigitalObject::UpdateFeaturedThumbnailRegion, type: :request do
  include_context 'with stubbed search adapters'
  let(:project) { FactoryBot.create(:project) }
  let(:authorized_object) { FactoryBot.create(:asset, :with_main_resource, primary_project: project) }
  let(:featured_thumbnail_region) { '5,10,100,100' }

  include_examples 'a basic user with no abilities is not authorized to perform this request' do
    let(:variables) { { input: { id: authorized_object.uid, featuredThumbnailRegion: featured_thumbnail_region } } }
    let(:request) { graphql query, variables }
  end

  context "when logged in user has appropriate permissions" do
    context 'when updating featured thumbnail region' do
      let(:variables) { { input: { id: authorized_object.uid, featuredThumbnailRegion: featured_thumbnail_region } } }

      before do
        sign_in_project_contributor to: :update_objects, project: project
        graphql query, variables
      end

      it "return a single asset with the expected featured thumbnail region" do
        expect(response.body).to be_json_eql("\"#{featured_thumbnail_region}\"").at_path('data/updateFeaturedThumbnailRegion/digitalObject/featuredThumbnailRegion')
      end

      it 'sets the region to the expected value' do
        expect(DigitalObject.find_by_uid!(authorized_object.uid).featured_thumbnail_region).to eq(featured_thumbnail_region)
      end

      context 'and an attempt is made to set a featured thumbnail region on a digital object type that does not have a featured thumbnail region field' do
        let(:authorized_object) { FactoryBot.create(:item, primary_project: project) }
        it 'fails on the target Item' do
          expect(response.body).to be_json_eql('"Items do not have a featured thumbnail region."').at_path('errors/0/message')
        end
      end
    end
  end

  def query
    <<~GQL
      mutation ($input: UpdateFeaturedThumbnailRegionInput!) {
        updateFeaturedThumbnailRegion(input: $input) {
          digitalObject {
            id
            ... on Asset {
              featuredThumbnailRegion
            }
          }
        }
      }
    GQL
  end
end
