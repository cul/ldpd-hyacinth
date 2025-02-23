require 'rails_helper'

RSpec.describe Hyacinth::Utils::PathUtils do
  describe '.pairtree' do
    let(:digest) { '3bf637408200bd7f04873f03a7aa5c97a792e2c9c89ce6b5d688fbc8353edfeb' }
    let(:original_filename) { 'example.tiff' }
    let(:original_filename_with_capital_letters_in_extension) { 'example.TiFf' }
    let(:original_filename_with_invalid_chars_in_extension) { 'example.jå¥pg' }

    it 'works as expected for a simple filename' do
      expect(described_class.pairtree(digest, original_filename)).to eq(
        ["3b", "f6", "37", "40", "3bf637408200bd7f04873f03a7aa5c97a792e2c9c89ce6b5d688fbc8353edfeb.tiff"]
      )
    end

    it 'downcases file extensions' do
      expect(described_class.pairtree(digest, original_filename_with_capital_letters_in_extension)).to eq(
        ["3b", "f6", "37", "40", "3bf637408200bd7f04873f03a7aa5c97a792e2c9c89ce6b5d688fbc8353edfeb.tiff"]
      )
    end

    it 'cleans file extensions to only allow periods, letters a-z and A-Z, and numbers' do
      expect(described_class.pairtree(digest, original_filename_with_invalid_chars_in_extension)).to eq(
        ["3b", "f6", "37", "40", "3bf637408200bd7f04873f03a7aa5c97a792e2c9c89ce6b5d688fbc8353edfeb.jpg"]
      )
    end
  end
end
