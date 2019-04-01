require 'rails_helper'

RSpec.describe DigitalObjectConcerns::DigitalObjectData::Setters do
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
  context "#set_digital_object_data" do
    it "calls the expected sub-methods and changes some data" do
      expect(digital_object_with_sample_data).to receive(:set_dynamic_field_data).with(digital_object_data, true).and_call_original
      expect(digital_object_with_sample_data).to receive(:set_doi).with(digital_object_data).and_call_original
      expect(digital_object_with_sample_data).to receive(:set_group).with(digital_object_data).and_call_original
      expect(digital_object_with_sample_data).to receive(:set_identifiers).with(digital_object_data).and_call_original
      expect(digital_object_with_sample_data).to receive(:set_mint_doi).with(digital_object_data).and_call_original
      expect(digital_object_with_sample_data).to receive(:set_optimistic_lock_token).with(digital_object_data).and_call_original
      expect(digital_object_with_sample_data).to receive(:set_parent_uids).with(digital_object_data).and_call_original
      expect(digital_object_with_sample_data).to receive(:set_publish_targets).with(digital_object_data).and_call_original
      expect(digital_object_with_sample_data).to receive(:set_resources).with(digital_object_data).and_call_original
      expect(digital_object_with_sample_data).to receive(:set_state).with(digital_object_data).and_call_original
      expect(digital_object_with_sample_data).to receive(:set_preserve).with(digital_object_data).and_call_original
      expect(digital_object_with_sample_data).to receive(:set_projects).with(digital_object_data).and_call_original

      digital_object_with_sample_data.set_digital_object_data(digital_object_data, true)

      expect(digital_object_with_sample_data.dynamic_field_data['title']).to eq([{
        'non_sort_portion' => 'The',
        'sort_portion' => 'Tall Man and His Hat'
      }])

      expect(digital_object_with_sample_data.dynamic_field_data['note']).to eq([{
        'note_value' => 'Great Note',
        'note_type' => 'So Great'
      }])
    end
  end
end
