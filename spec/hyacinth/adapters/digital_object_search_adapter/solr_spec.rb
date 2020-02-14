# frozen_string_literal: true

require 'rails_helper'
require 'shared_examples/digital_object_search_adapter/shared_examples'

describe Hyacinth::Adapters::DigitalObjectSearchAdapter::Solr do
  let(:adapter) { described_class.new(url: "http://nowhere.net/solr") }

  it_behaves_like "a search adapter"

  context "#solr_params_for" do
    let(:solr_params) { adapter.solr_params_for(search_params) }
    context "with multiple filter values on the same filter" do
      let(:search_params) { { 'animals' => ['dogs', 'cats'] } }
      it "collects fq values" do
        expect(solr_params.to_h).to include(fq: ['animals:"dogs"', 'animals:"cats"'])
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

    it "indexes the uid into id" do
      expect(adapter.solr_document_for(authorized_object)['id']).to eql(authorized_object.uid)
    end

    it "indexes the digital object type" do
      expect(adapter.solr_document_for(authorized_object)['digital_object_type_ssi']).to eql(authorized_object.digital_object_type)
    end

    it "indexes the title into title_ssi" do
      pending("object factory field name corrections to align with title practice")
      expect(adapter.solr_document_for(authorized_object)['title_ssi']).to eql('Tall Man and His Hat')
    end
  end
end
