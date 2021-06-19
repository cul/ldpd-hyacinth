# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DigitalObjectConcerns::IndexBehavior, solr: true do
  let(:digital_object_with_sample_data) { FactoryBot.create(:digital_object_test_subclass, :with_sample_data) }
  let(:search_params) { { id: digital_object_with_sample_data.uid } }
  context "#index" do
    let!(:prior) do
      digital_object_with_sample_data
      results = Hyacinth::Config.digital_object_search_adapter.search(search_params)
      results['response']['docs'].first
    end
    it "works as expected, updating the saved object in the index" do
      sleep 0.1
      digital_object_with_sample_data.index
      current = Hyacinth::Config.digital_object_search_adapter.search(search_params)['response']['docs'].first
      expect(Time.zone.parse(current['timestamp'])).to be > Time.zone.parse(prior['timestamp'])
    end
  end

  context "#deindex" do
    it "runs as expected, removing the destroyed object from the index" do
      expect(Hyacinth::Config.digital_object_search_adapter.search(search_params)['response']['docs']).to be_present
      digital_object_with_sample_data.deindex
      expect(Hyacinth::Config.digital_object_search_adapter.search(search_params)['response']['docs']).to be_blank
    end
  end

  # TODO: Create these tests
  # context "#index_test" do
  #   it "returns true when indexing would produce a valid index document" do
  #     pending
  #   end
  #   it "returns false when indexing would not produce a valid index document" do
  #     pending
  #   end
  # end
end
