# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DigitalObjectConcerns::IndexBehavior, solr: true do
  let(:digital_object_with_sample_data) { FactoryBot.create(:digital_object_test_subclass, :with_sample_data) }
  let(:search_params) { { id: digital_object_with_sample_data.uid } }
  context "#save" do
    let!(:prior) do
      results = Hyacinth::Config.digital_object_search_adapter.search(search_params)
      results['response']['docs'].first
    end
    it "runs as expected, updating the saved object in the index" do
      digital_object_with_sample_data.save
      results = Hyacinth::Config.digital_object_search_adapter.search(search_params)
      curr = results['response']['docs'].first
      expect(curr["timestamp"]).to be > prior["timestamp"]
    end
  end

  context "#destroy" do
    it "runs as expected, removing the destroyed object from the index" do
      digital_object_with_sample_data.destroy
      results = Hyacinth::Config.digital_object_search_adapter.search(search_params)
      expect(results['response']['docs']).to be_blank
    end
  end
end
