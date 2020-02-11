# frozen_string_literal: true

require 'rails_helper'
require 'shared_examples/storage_adapter/shared_examples'

RSpec.describe Hyacinth::Adapters::StorageAdapter::AbstractReadableWritable do
  let(:adapter) { described_class.new(uri_protocol: 'abstract-readable-writable') }
  it_behaves_like "a readable storage adapter"
  it_behaves_like "a writable storage adapter"
end
