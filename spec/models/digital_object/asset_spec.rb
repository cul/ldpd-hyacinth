# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DigitalObject::Asset, type: :model do
  describe "primary resource validations" do
    let(:asset) { FactoryBot.build(:asset) }
    it "fails if there is no resource or resource_import entry for the primary resource" do
      asset.save
      expect(asset.errors.keys).to include(:"resources[#{asset.main_resource_name}]", :asset_type)
    end
  end

  describe "type validations" do
    let(:asset) { FactoryBot.build(:asset, :with_main_resource) }
    it "works for all valid values" do
      failed = BestType::PcdmTypeLookup::VALID_TYPES.detect do |type|
        asset.asset_type = type
        !asset.valid?
      end
      expect(failed).to be_nil
    end
    it "fails for invalid values" do
      failed = BestType::PcdmTypeLookup::VALID_TYPES.detect do |type|
        asset.asset_type = type.reverse
        !asset.valid?
      end
      expect(failed).to be BestType::PcdmTypeLookup::VALID_TYPES.first
    end
  end

  describe "image_size_restriction validation" do
    let(:asset) { FactoryBot.build(:asset, :with_main_resource) }
    before { asset.asset_type = BestType::PcdmTypeLookup::VALID_TYPES.first }
    it "allows valid values" do
      Hyacinth::DigitalObject::Asset::ImageSizeRestriction::VALID_IMAGE_SIZE_RESTRICTIONS.each do |value|
        asset.image_size_restriction = value
        expect(asset.valid?).to be true
      end
    end
    it "rejects an invalid value" do
      asset.image_size_restriction = 'invalid'
      expect(asset.valid?).to be false
    end
  end

  describe "the run_resource_requests after_save callback method" do
    let(:asset) { FactoryBot.build(:asset, :with_main_resource) }

    # TODO: Need to update to the way that digital objects save, since deep_clone method
    # (which uses Marshal.dump) isn't compatible with rspec mocks.

    it 'runs after save' do
      # TODO: Use commented out code instead when DigitalObject#save method works with rspec mocks
      # expect(asset).to receive(:run_resource_requests).and_call_original
      # TODO: Replace line below with line above
      expect(ResourceRequests::AccessJob).to receive(:perform_later_if_eligible)

      asset.save
    end

    it 'does not run after save if skip_resource_request_callbacks is set to true' do
      asset.skip_resource_request_callbacks = true

      # TODO: Use commented out code instead when DigitalObject#save method works with rspec mocks
      # expect(asset).not_to receive(:run_resource_requests).and_call_original
      # TODO: Replace line below with line above
      expect(ResourceRequests::AccessJob).not_to receive(:perform_later_if_eligible)
      asset.save
    end
  end
end
