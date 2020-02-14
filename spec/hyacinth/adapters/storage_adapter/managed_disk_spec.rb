# frozen_string_literal: true

require 'rails_helper'
require 'shared_examples/storage_adapter/shared_examples'
require 'shared_examples/storage_adapter/disk_shared_examples'

RSpec.describe Hyacinth::Adapters::StorageAdapter::ManagedDisk do
  let(:uri_protocol) { 'managed-disk' }
  let(:default_path) { File.join(Dir.tmpdir, 'storage_adapter_disk') }
  let(:adapter) { described_class.new(uri_protocol: uri_protocol, default_path: default_path) }
  let(:expected_adapter_uri_prefix) { "#{uri_protocol}://" }
  let(:example_file_path) { File.join(default_path, 'file.txt') }
  let(:sample_location_uri) { expected_adapter_uri_prefix + example_file_path }
  let(:content) { 'This text should be stored.' }

  let(:new_record_identifier) { 'abcdefghijklmnopqrstuvwxyz' }
  let(:expected_new_location_uri) { "#{expected_adapter_uri_prefix}#{default_path}/71/c4/80/df/93/d6/71c480df93d6ae2f1efad1447c66c9525e316218cf51fc8d9ed832f2daf18b73" }

  # Create sample file so it can be read by the adapter in read tests
  before do
    adapter.write(sample_location_uri, content)
  end

  # Clear default_path after each test is done so we don't
  # leave extra files or directories lying around.
  after { FileUtils.rm_rf(default_path) }

  it_behaves_like "a readable-writable storage adapter"
  it_behaves_like "a readable-writable disk storage adapter"
end
