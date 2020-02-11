# frozen_string_literal: true

require 'rails_helper'
require 'shared_examples/storage_adapter/shared_examples'

RSpec.describe Hyacinth::Adapters::StorageAdapter::AbstractReadable do
  let(:adapter) { described_class.new(uri_protocol: 'abstract-readable') }
  it_behaves_like "a readable storage adapter"
end
