require 'rails_helper'

RSpec.describe DigitalObject::Asset, type: :model do
  let(:asset) { described_class.new }
  describe "type validations" do
    it "works for all valid values" do
      failed = Hyacinth::DigitalObject::AssetType::VALID_TYPES.detect do |type|
        asset.asset_type = type
        !asset.valid?
      end
      expect(failed).to be_nil
    end
    it "fails for invalid values" do
      failed = Hyacinth::DigitalObject::AssetType::VALID_TYPES.detect do |type|
        asset.asset_type = type.reverse
        !asset.valid?
      end
      expect(failed).to be Hyacinth::DigitalObject::AssetType::VALID_TYPES.first
    end
  end
end
