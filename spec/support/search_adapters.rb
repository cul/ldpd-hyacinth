# frozen_string_literal: true

shared_context 'with stubbed search adapters' do
  let(:search_adapter) { instance_double(Hyacinth::Adapters::DigitalObjectSearchAdapter::Solr) }
  let(:term_search_adapter) { instance_double(Hyacinth::Adapters::TermSearchAdapter::Solr) }
  before do
    allow(Hyacinth::Config).to receive(:digital_object_search_adapter).and_return(search_adapter)
    allow(search_adapter).to receive(:index).with(a_kind_of(DigitalObject))
    allow(search_adapter).to receive(:index_test).with(a_kind_of(DigitalObject)).and_return(true)
    allow(search_adapter).to receive(:remove).with(a_kind_of(DigitalObject))
    allow(search_adapter).to receive(:search_types).and_return(['keyword'])

    allow(Hyacinth::Config).to receive(:term_search_adapter).and_return(term_search_adapter)
    allow(term_search_adapter).to receive(:batch_find).and_return([])
    allow(term_search_adapter).to receive(:add).with(a_kind_of(Hash))
    allow(term_search_adapter).to receive(:delete).with(String)
  end
end

shared_context 'with stubbed search result' do
  let(:document_generator) { Hyacinth::Adapters::DigitalObjectSearchAdapter::Solr::DocumentGenerator.new }
  let(:mock_solr_doc) { document_generator.solr_document_for(authorized_object) }
  let(:solr_request) { { params: { 'rows' => 1, 'start' => 0 } } }
  let(:solr_result) do
    {
      "response" => {
        "numFound" => 1,
        "docs" => [mock_solr_doc]
      },
      "facet_counts" => {

      }
    }
  end
  # Basic Solr response hash structure
  let(:solr_response) do
    RSolr::HashWithResponse.new(solr_request, {}, solr_result)
  end
  before do
    allow(search_adapter).to receive(:search).and_return(solr_response)
  end
end
