require 'rails_helper'

RSpec.shared_examples 'DigitalObjectConcerns::DigitalObjectData::Serializer' do
  include_context 'sample digital_object_subclass and digital_object_subclass_instance'

  context "#to_digital_object_data" do
    let (:digital_object_data) { digital_object_subclass_instance.to_digital_object_data }
    it "returns a Hash with keys for all defined attributes, and all resources under a 'resources' key" do
      expect(digital_object_data).to be_a(Hash)
      expect(
        digital_object_data.keys.sort
      ).to eq(
        digital_object_subclass_instance.metadata_attributes.keys.push('resources').map { |key| key.to_s }.sort
      )
    end

    it "returns the expected custom resource keys, nested under a top 'resources' key" do
      expect(digital_object_data).to be_a(Hash)
      expect(
        digital_object_data['resources'].keys.sort
      ).to eq(
        digital_object_subclass_instance.resource_attributes.keys.map { |key| key.to_s }.sort
      )
    end
  end
end
