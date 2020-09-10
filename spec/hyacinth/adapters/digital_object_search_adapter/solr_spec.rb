# frozen_string_literal: true

require 'rails_helper'
require 'shared_examples/digital_object_search_adapter/shared_examples'

describe Hyacinth::Adapters::DigitalObjectSearchAdapter::Solr do
  let(:adapter) { described_class.new(url: "http://nowhere.net/solr") }

  it_behaves_like "a search adapter"

  context "#solr_params_for" do
    let(:solr_params) { adapter.solr_params_for(search_params) }
    context "with multiple filter values on the same filter" do
      let(:search_params) do
        {
          'animals' => [
            ['aardvarks', 'absent'], ['celocanths', 'contains'], ['elephants', 'matches'],
            ['ostriches', 'omits'], ['panthers', 'present'], ['voles', 'varies']
          ]
        }
      end
      let(:expected_filters) do
        [
          'state_ssi:(active)', '-animals:*', 'animals:(*celocanths*)', 'animals:(elephants)',
          '-animals:(*ostriches*)', 'animals:*', '-animals:(voles)'
        ]
      end
      it "collects fq values" do
        expect(solr_params.to_h).to include(fq: expected_filters)
      end
    end
    context "with a search type parameter" do
      let(:search_params) { { 'search_type' => 'identifier' } }
      it "assigns df value" do
        expect(solr_params.to_h).to include(df: 'identifier_search_sim')
      end
    end
  end

  context "#solr_document_for" do
    let(:authorized_object) { FactoryBot.build(:digital_object_test_subclass, :with_sample_data) }
    let(:publication_adapter) { Hyacinth::Adapters::PublicationAdapter::Abstract.new }
    let!(:external_identifier_adapter) { Hyacinth::Adapters::ExternalIdentifierAdapter::Memory.new }

    before do
      authorized_object.send :uid=, 'dummy-uid'
      allow(Hyacinth::Config).to receive(:publication_adapter).and_return(publication_adapter)
      allow(Hyacinth::Config).to receive(:external_identifier_adapter).and_return(external_identifier_adapter)
    end

    it "delegates to an adapter" do
      delegate = instance_double(Hyacinth::Adapters::DigitalObjectSearchAdapter::Solr::DocumentGenerator)
      adapter.instance_variable_set(:@document_generator, delegate)
      expect(delegate).to receive(:solr_document_for)
      adapter.solr_document_for(authorized_object)
    end
  end
end
