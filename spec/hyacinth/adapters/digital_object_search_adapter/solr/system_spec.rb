# frozen_string_literal: true

require 'rails_helper'
require 'shared_examples/digital_object_search_adapter/shared_examples'

# TODO: HYACINTH-840 Refactor this to permit configuration of in-memory impl for test
# - create an independent instance of Hyacinth::Adapters::DigitalObjectSearchAdapter::Solr here
describe Hyacinth::Adapters::DigitalObjectSearchAdapter::Solr, solr: true do
  let(:adapter) { Hyacinth::Config.digital_object_search_adapter }
  describe "#remove" do
    let(:authorized_object) { FactoryBot.create(:digital_object_test_subclass, :with_sample_data) }
    let(:object_uid) { authorized_object.uid }

    it "removes on destroy" do
      response = adapter.search(id: object_uid)['response']
      expect(response['numFound']).to be 1
      authorized_object.destroy
      response = adapter.search(id: object_uid)['response']
      expect(response['numFound']).to be 0
    end
  end
end
