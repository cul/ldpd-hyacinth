# frozen_string_literal: true

require 'rails_helper'
require 'shared_examples/storage_adapter/shared_examples'
require 'shared_examples/storage_adapter/disk_shared_examples'

RSpec.describe Hyacinth::Adapters::StorageAdapter::TrackedDisk do
  let(:uri_protocol) { 'tracked-disk' }
  let(:adapter) { described_class.new(uri_protocol: uri_protocol) }
  let(:expected_adapter_uri_prefix) { "#{uri_protocol}://" }
  let(:example_file_path) { Rails.root.join('spec', 'fixtures', 'files', 'test.txt').to_s }
  let(:sample_location_uri) { expected_adapter_uri_prefix + example_file_path }
  let(:content) { 'What a great test file!' }

  it_behaves_like "a readable storage adapter"
  it_behaves_like "a readable disk storage adapter"

  it "is not writable" do
    expect(adapter.writable?).to eq(false)
  end

  context "#delete" do
    it "raises an exception" do
      expect { adapter.delete(sample_location_uri) }.to raise_error(Hyacinth::Exceptions::DeletionError)
    end

    it "does not delete the file at the given location" do
      adapter.delete(sample_location_uri)
    rescue # rubocop:disable Lint/HandleExceptions
    ensure
      expect(adapter.exists?(example_file_path)).to eq(true)
    end
  end
end
