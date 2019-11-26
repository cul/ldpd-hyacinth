# frozen_string_literal: true

require 'rails_helper'
require 'shared_examples/storage_adapter/shared_examples'

RSpec.describe Hyacinth::Adapters::StorageAdapter::Abstract do
  let(:adapter) { described_class.new }
  it_behaves_like "a storage adapter"
end
