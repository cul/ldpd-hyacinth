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
  before do
    # This shared spec requires the including context to define variables:
    raise 'Must define new_record_identifier via let(:new_record_identifier)' unless defined?(new_record_identifier)
    raise 'Must define expected_new_location_uri via let(:expected_new_location_uri)' unless defined?(expected_new_location_uri)
  end

  it_behaves_like "a readable disk storage adapter"

  it "#generate_new_location_uri" do
    expect(adapter.generate_new_location_uri(new_record_identifier)).to eq(expected_new_location_uri)
  end
end
