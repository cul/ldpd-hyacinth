# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DigitalObjectConcerns::Assets::Validations do
  let(:asset) { FactoryBot.build(:asset, :with_master_resource) }

  describe '.validate_master_resource' do
    it 'fails validation when main resource is not present' do
      asset.delete_resource(asset.master_resource_name)
      expect(asset.save).to eq(false)
      expect(asset.errors.keys).to include(:"resources[#{asset.master_resource_name}]")
    end
  end

  describe '.validate_asset_type' do
    it 'fails validation when asset_type is not present' do
      asset.asset_type = nil
      expect(asset.save).to eq(false)
      expect(asset.errors.keys).to include(:asset_type)
    end

    it 'fails validation when asset_type is not an allowed value' do
      asset.asset_type = 'banana'
      expect(asset.save).to eq(false)
      expect(asset.errors.keys).to include(:asset_type)
    end
  end

  describe '.validate_rights_updates' do
    before do
      Hyacinth::DynamicFieldsLoader.load_rights_fields!(load_vocabularies: true)
      asset.assign_rights({ 'rights' => { 'copyright_status_override' => [{ 'note' => "A copyright note." }] } }, false)
    end

    it 'passes when asset rights are enabled for the primary project' do
      asset.primary_project.has_asset_rights = true
      asset.primary_project.save!
      expect(asset.save).to eq(true)
    end

    it 'fails when asset rights are not enabled for the primary project' do
      expect(asset.save).to eq(false)
      expect(asset.errors.keys).to include(:rights)
    end
  end

  describe '.validate_featured_thumbnail_region' do
    it 'fails validation when main resource is not present' do
      asset.delete_resource(asset.master_resource_name)
      expect(asset.save).to eq(false)
      expect(asset.errors.keys).to include(:"resources[#{asset.master_resource_name}]")
    end
  end

  describe '.validate_featured_thumbnail_region' do
    it 'passes validation for a valid region' do
      asset.featured_thumbnail_region = '1,2,100,100'
      expect(asset.save).to eq(true)
    end

    it 'fails validation for an invalid-format region' do
      asset.featured_thumbnail_region = '1,2'
      expect(asset.save).to eq(false)
      expect(asset.errors.keys).to include(:featured_thumbnail_region)
    end

    it 'fails validation for a valid format region that is not a square' do
      asset.featured_thumbnail_region = '1,2,3,4'
      expect(asset.save).to eq(false)
      expect(asset.errors.keys).to include(:featured_thumbnail_region)
    end
  end
end
