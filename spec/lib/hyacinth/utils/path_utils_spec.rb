require 'rails_helper'

RSpec.describe Hyacinth::Utils::PathUtils do
  describe '.asset_file_pairtree' do
    let(:digest) { '3bf637408200bd7f04873f03a7aa5c97a792e2c9c89ce6b5d688fbc8353edfeb' }
    let(:suffix) { '-access' }
    let(:extension) { 'tiff' }
    let(:extension_with_leading_period) { '.tiff' }
    let(:extension_with_capital_letters) { 'TiFf' }
    let(:extension_with_invalid_chars) { 'jå¥pg' }

    it 'works as expected for a simple extension' do
      expect(described_class.asset_file_pairtree(digest, suffix, extension)).to eq(
        ["3b", "f6", "37", "40", "3bf637408200bd7f04873f03a7aa5c97a792e2c9c89ce6b5d688fbc8353edfeb-access.tiff"]
      )
    end

    it 'works as expected when a leading period is provided with the extension' do
      expect(described_class.asset_file_pairtree(digest, suffix, extension_with_leading_period)).to eq(
        ["3b", "f6", "37", "40", "3bf637408200bd7f04873f03a7aa5c97a792e2c9c89ce6b5d688fbc8353edfeb-access.tiff"]
      )
    end

    it 'downcases file extensions' do
      expect(described_class.asset_file_pairtree(digest, suffix, extension_with_capital_letters)).to eq(
        ["3b", "f6", "37", "40", "3bf637408200bd7f04873f03a7aa5c97a792e2c9c89ce6b5d688fbc8353edfeb-access.tiff"]
      )
    end

    it 'cleans file extensions to only allow periods, letters a-z and A-Z, and numbers' do
      expect(described_class.asset_file_pairtree(digest, suffix, extension_with_invalid_chars)).to eq(
        ["3b", "f6", "37", "40", "3bf637408200bd7f04873f03a7aa5c97a792e2c9c89ce6b5d688fbc8353edfeb-access.jpg"]
      )
    end
  end
end
