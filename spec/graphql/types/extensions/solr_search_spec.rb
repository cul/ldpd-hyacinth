# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Types::Extensions::SolrSearch do
  context "stateless methods" do
    let(:client) do
      # do nothing with initialization; we just want to test stateless methods
      described_class.allocate
    end
    describe "#after_resolve" do
      let(:offset) { 20 }
      let(:limit) { 10 }
      let(:arguments) { { offset: offset, limit: limit } }
      let(:solr_request) { { params: { 'rows' => limit, 'start' => offset } } }
      let(:solr_result) do
        {
          "response" => {
            "numFound" => total_count,
            "docs" => []
          },
          "facet_counts" => {

          }
        }
      end
      # Basic Solr response hash structure
      let(:value) do
        RSolr::HashWithResponse.new(solr_request, {}, solr_result)
      end
      let(:after_resolve) { client.after_resolve(object: nil, value: value, arguments: arguments, context: nil, memo: nil) }

      context "there are more pages" do
        let(:total_count) { offset + limit + 1 }
        it "returns an OpenStruct supporting pagination" do
          expect(after_resolve).to be_a(OpenStruct)
          expect(after_resolve.page_info.has_next_page).to be true
          expect(after_resolve.page_info.has_previous_page).to be true
        end
      end
      context "there aren't more pages" do
        let(:total_count) { offset + limit }
        it "returns an OpenStruct supporting pagination" do
          expect(after_resolve).to be_a(OpenStruct)
          expect(after_resolve.page_info.has_next_page).to be false
          expect(after_resolve.page_info.has_previous_page).to be true
        end
        context "or previous pages" do
          let(:offset) { 0 }
          it "returns an OpenStruct supporting pagination" do
            expect(after_resolve).to be_a(OpenStruct)
            expect(after_resolve.page_info.has_next_page).to be false
            expect(after_resolve.page_info.has_previous_page).to be false
          end
        end
      end
    end
    describe "#facets" do
      # Solr returns facet values and counts as a flattened array per faceted field
      let(:facet_counts) do
        {
          "facet_fields" => {
            "digital_object_type_ssi" => [
              "asset", 2,
              "item", 1
            ]
          }
        }
      end
      let(:facet_list) { client.facets(facet_counts) }
      let(:asset) { facet_list.first[:values].detect { |value| value[:value] == 'asset' } }
      let(:item) { facet_list.first[:values].detect { |value| value[:value] == 'item' } }

      it "parses the solr facets array into a suitable hash of values and counts" do
        expect(item[:count]).to be 1
        expect(asset[:count]).to be 2
      end
    end
  end
end
