# frozen_string_literal: true

require 'rails_helper'
require 'shared_examples/storage_adapter/shared_examples'

RSpec.describe Hyacinth::Adapters::StorageAdapter::Memory do
  let(:expected_adapter_uri_prefix) { 'memory://' }
  let(:sample_location_uri) { expected_adapter_uri_prefix + 'anything' }
  let(:adapter) { described_class.new }

  it_behaves_like "a storage adapter"

  context "#uri_prefix" do
    it "has the expected prefix" do
      expect(adapter.uri_prefix).to eq(expected_adapter_uri_prefix)
    end
  end

  context "reading and writing" do
    let(:content) { 'This text should be stored.' }

    it "can write content and then read that written content" do
      adapter.write(sample_location_uri, content)
      expect(adapter.read(sample_location_uri)).to eq(content)
    end

    it "can write to streamable content and then read that written content" do
      adapter.with_writeable(sample_location_uri) do |blob|
        blob.write content
      end
      expect(adapter.read(sample_location_uri)).to eq(content)
    end

    context "reject unhandled URIs" do
      let(:unhandled_location_uri) { 'unhandled:///a/b/c/d/e' }
      it "rejects for read" do
        expect { adapter.read(unhandled_location_uri) }.to raise_error(Hyacinth::Exceptions::UnhandledLocationError)
      end

      it "rejects for write" do
        expect { adapter.write(unhandled_location_uri, content) }.to raise_error(Hyacinth::Exceptions::UnhandledLocationError)
      end
    end
  end
end
