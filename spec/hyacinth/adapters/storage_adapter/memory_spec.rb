# frozen_string_literal: true

require 'rails_helper'
require 'shared_examples/storage_adapter/shared_examples'

RSpec.describe Hyacinth::Adapters::StorageAdapter::Memory do
  let(:uri_protocol) { 'great-memory' }
  let(:adapter) { described_class.new(uri_protocol: uri_protocol) }
  let(:expected_adapter_uri_prefix) { "#{uri_protocol}://" }
  let(:sample_location_uri) { expected_adapter_uri_prefix + 'anything' }
  let(:content) { 'This text should be stored.' }

  it_behaves_like "a readable-writable storage adapter" do
    before do
      adapter.write(sample_location_uri, content)
    end
  end
end
