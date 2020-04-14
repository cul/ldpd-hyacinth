# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples "a readable disk storage adapter" do
  before do
    # This shared spec requires the including context to define variables:
    raise 'Must define example_file_path via let(:example_file_path)' unless defined?(example_file_path)
  end

  it "#location_uri_to_file_path" do
    expect(adapter.location_uri_to_file_path(sample_location_uri)).to eq(example_file_path)
  end
end

RSpec.shared_examples "a readable-writable disk storage adapter" do
  it_behaves_like "a readable disk storage adapter"
end
