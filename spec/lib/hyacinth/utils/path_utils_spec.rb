require 'rails_helper'

RSpec.describe Hyacinth::Utils::PathUtils do
  describe '.relative_resource_file_path_for_uuid' do
    let(:uuid) { '3229414b-50be-4137-a360-fa97f043e2f5' }
    let(:project) { FactoryBot.build(:project, string_key: 'example_project') }
    let(:suffix) { '-access' }
    let(:extension) { 'tiff' }
    let(:extension_with_leading_period) { '.tiff' }
    let(:extension_with_capital_letters) { 'TiFf' }
    let(:extension_with_invalid_chars) { 'jå¥pg' }

    it 'works as expected for a simple extension' do
      expect(described_class.relative_resource_file_path_for_uuid(uuid, project, suffix, extension)).to eq(
        'example_project/32/29/41/4b/50/be/3229414b-50be-4137-a360-fa97f043e2f5/3229414b-50be-4137-a360-fa97f043e2f5-access.tiff'
      )
    end

    it 'works as expected when a leading period is provided with the extension' do
      expect(described_class.relative_resource_file_path_for_uuid(uuid, project, suffix, extension_with_leading_period)).to eq(
        'example_project/32/29/41/4b/50/be/3229414b-50be-4137-a360-fa97f043e2f5/3229414b-50be-4137-a360-fa97f043e2f5-access.tiff'
      )
    end

    it 'downcases file extensions' do
      expect(described_class.relative_resource_file_path_for_uuid(uuid, project, suffix, extension_with_capital_letters)).to eq(
        'example_project/32/29/41/4b/50/be/3229414b-50be-4137-a360-fa97f043e2f5/3229414b-50be-4137-a360-fa97f043e2f5-access.tiff'
      )
    end

    it 'cleans file extensions to only allow periods, letters a-z and A-Z, and numbers' do
      expect(described_class.relative_resource_file_path_for_uuid(uuid, project, suffix, extension_with_invalid_chars)).to eq(
        'example_project/32/29/41/4b/50/be/3229414b-50be-4137-a360-fa97f043e2f5/3229414b-50be-4137-a360-fa97f043e2f5-access.jpg'
      )
    end
  end
end
