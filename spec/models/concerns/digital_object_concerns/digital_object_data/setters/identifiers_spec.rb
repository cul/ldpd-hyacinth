require 'rails_helper'

RSpec.describe DigitalObjectConcerns::DigitalObjectData::Setters::Identifiers do
  let(:identifiers) { Set['id1', 'id2', 'id3'] }
  let(:different_identifiers) { Set['id4', 'id5', 'id6'] }
  let(:digital_object) { FactoryBot.build(:digital_object_test_subclass) }
  let(:digital_object_data_with_identifiers) do
    { 'identifiers' => identifiers.to_a }
  end
  let(:digital_object_data_with_different_identifiers) do
    { 'identifiers' => different_identifiers.to_a }
  end

  context "#set_identifiers" do
    it "sets the identifiers each time it's called" do
      expect(digital_object.identifiers).to be_blank
      digital_object.set_identifiers(digital_object_data_with_identifiers)
      expect(digital_object.identifiers).to eq(identifiers)
      digital_object.set_identifiers(digital_object_data_with_different_identifiers)
      expect(digital_object.identifiers).to eq(different_identifiers)
    end
  end
end
