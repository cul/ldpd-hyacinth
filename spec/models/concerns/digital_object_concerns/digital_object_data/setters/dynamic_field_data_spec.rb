require 'rails_helper'

RSpec.describe DigitalObjectConcerns::DigitalObjectData::Setters::DynamicFieldData do
  let(:digital_object_with_sample_data) { FactoryBot.build(:digital_object_test_subclass, :with_sample_data) }
  let(:digital_object_data) do
    {
      'dynamic_field_data' => {
        'note' => [
          {
            'note_value' => 'Great Note',
            'note_type' => 'So Great'
          }
        ]
      }
    }
  end
  context "#set_dynamic_field_data" do
    it "merges dynamic field data when merge param is true" do
      digital_object_with_sample_data.set_dynamic_field_data(digital_object_data, true)
      expect(digital_object_with_sample_data.dynamic_field_data['title']).to eq([{
        'non_sort_portion' => 'The',
        'sort_portion' => 'Tall Man and His Hat'
      }])

      expect(digital_object_with_sample_data.dynamic_field_data['note']).to eq([{
        'note_value' => 'Great Note',
        'note_type' => 'So Great'
      }])
    end

    it "merges dynamic field data when merge param is false" do
      digital_object_with_sample_data.set_dynamic_field_data(digital_object_data, false)
      expect(digital_object_with_sample_data.dynamic_field_data['title']).to be_nil

      expect(digital_object_with_sample_data.dynamic_field_data['note']).to eq([{
        'note_value' => 'Great Note',
        'note_type' => 'So Great'
      }])
    end
  end
end
