# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Types::Extensions::MapToDigitalObjects do
  context "stateless methods" do
    let(:client) do
      # do nothing with initialization; we just want to test stateless methods
      described_class.allocate
    end
    describe "#after_resolve" do
      let(:id_from_solr) { 'id_from_solr' }
      # paginated value nodes should be solr document hashes with ids
      let(:value) do
        OpenStruct.new(
          nodes: [{ 'id' => id_from_solr }],
          page_info: OpenStruct.new
        )
      end

      it "parses the solr facets array into a suitable hash of values and counts" do
        expect(::DigitalObject::Base).to receive(:find).with(id_from_solr)
        client.after_resolve(object: nil, value: value, arguments: {}, context: nil, memo: nil)
      end
    end
  end
end
