# frozen_string_literal: true

require 'rails_helper'
require 'shared_examples/storage_adapter/shared_examples'

RSpec.describe Hyacinth::Adapters::StorageAdapter::ManagedDisk do
  let(:uri_protocol) { 'spinning-disk' }
  let(:default_path) { File.join(Dir.tmpdir, 'storage_adapter_disk') }
  let(:adapter) { described_class.new(uri_protocol: uri_protocol, default_path: default_path) }
  let(:sample_full_file_path) { File.join(default_path, 'file.txt') }
  let(:expected_adapter_uri_prefix) { "#{uri_protocol}://" }
  let(:sample_location_uri) { expected_adapter_uri_prefix + sample_full_file_path }

  # Clear default_path after each test is done so we don't
  # leave extra files or directories lying around.
  after { FileUtils.rm_rf(default_path) }

  it_behaves_like "a readable storage adapter"
  it_behaves_like "a writable storage adapter"

  context "#uri_prefix" do
    it "has the expected prefix" do
      expect(adapter.uri_prefix).to eq(expected_adapter_uri_prefix)
    end
  end

  context "#location_uri_to_file_path" do
    it "converts as expected" do
      expect(adapter.location_uri_to_file_path(sample_location_uri)).to eq(sample_full_file_path)
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
