# frozen_string_literal: true

require 'rails_helper'
require 'shared_examples/lock_adapter/shared_examples'

RSpec.describe Hyacinth::Adapters::LockAdapter::Abstract do
  let(:adapter) { described_class.new }
  it_behaves_like "a lock adapter"
end
