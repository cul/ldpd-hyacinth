require 'rails_helper'

RSpec.describe Hyacinth::Utils::UriUtils do
  describe '.file_path_to_location_uri' do
    it 'converts as expected' do
      expect(described_class.file_path_to_location_uri('/a/b/c.png')).to eq('file:///a/b/c.png')
    end

    it 'raises an ArgumentError if the given path is not an absolute file path' do
      expect { described_class.file_path_to_location_uri('a/b/c.png') }.to raise_error(ArgumentError)
    end
  end

  describe '.location_uri_to_file_path' do
    {
      'file:///a/b/c.png' => '/a/b/c.png',
    }.each do |location_uri, expected_file_path|
      it 'converts as expected ' do
        expect(described_class.location_uri_to_file_path(location_uri)).to eq(expected_file_path)
      end
    end

    it 'raises an ArgumentError if the given uri uses an unsupported scheme' do
      expect { described_class.location_uri_to_file_path('unknown:///a/b/c.png') }.to raise_error(ArgumentError)
    end
  end
end
