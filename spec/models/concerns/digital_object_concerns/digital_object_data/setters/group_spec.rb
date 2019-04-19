require 'rails_helper'

RSpec.describe DigitalObjectConcerns::DigitalObjectData::Setters::Group do
  let(:group) { FactoryBot.create(:group) }
  let(:another_group) { FactoryBot.create(:group, string_key: 'another_group') }
  let(:digital_object) { FactoryBot.build(:digital_object_test_subclass) }
  let(:digital_object_data_with_group) do
    { 'group' => { 'string_key' => group.string_key } }
  end
  let(:digital_object_data_with_another_group) do
    { 'group' => { 'string_key' => another_group.string_key } }
  end

  context "#set_group" do
    it "sets the group each time it's called" do
      expect(digital_object.group).to be_blank
      digital_object.set_group(digital_object_data_with_group)
      expect(digital_object.group).to eq(group)
      digital_object.set_group(digital_object_data_with_another_group)
      expect(digital_object.group).to eq(another_group)
    end
  end
end
