# frozen_string_literal: true

require 'rails_helper'

describe Hyacinth::DigitalObject::ResourceHelper do
  describe '.resource_location_for_derivativo' do
    let(:disk_based_resource) { Hyacinth::DigitalObject::Resource.new(location: 'managed-disk:///path/to/file') }
    let(:non_disk_based_resource) { Hyacinth::DigitalObject::Resource.new(location: 'memory://12345') }

    it 'returns the expected value for a disk-based resource' do
      expect(described_class.resource_location_uri(disk_based_resource)).to eq('file:///path/to/file')
    end

    it 'returns the expected value for a NON-disk-based resource' do
      expect { described_class.resource_location_uri(non_disk_based_resource) }.to raise_error(NotImplementedError)
    end
  end
end
