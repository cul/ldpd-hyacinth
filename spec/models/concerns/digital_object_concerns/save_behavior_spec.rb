# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DigitalObjectConcerns::SaveBehavior, solr: true do
  let(:digital_object_with_sample_data) { FactoryBot.build(:digital_object_test_subclass, :with_sample_data) }

  context "#flat_child_uid_set" do
    it "works as expected for a flat sequence" do
      allow(digital_object_with_sample_data).to receive(:structured_children).and_return({
        'type' => 'sequence',
        'structure' => ['child-111', 'child-222', 'child-333']
      })
      expect(digital_object_with_sample_data.flat_child_uid_set).to eq(Set['child-111', 'child-222', 'child-333'])
    end
  end

  context "#save" do
    it "runs as expected, returning true when a valid object is saved successfully, and doesn't have any errors in the #errors array" do
      success = digital_object_with_sample_data.save
      expect(digital_object_with_sample_data.errors.empty?).to eq(true)
      expect(success).to eq(true)
    end

    it "returns false when an invalid object fails to save, and adds errors to #errors array" do
      digital_object_with_sample_data.state = 'invalid state'
      expect(digital_object_with_sample_data.save).to eq(false)
      expect(digital_object_with_sample_data.errors).to be_present
      expect(digital_object_with_sample_data.errors.include?(:state)).to eq(true)
    end

    context "with added parents" do
      let(:parent1) { FactoryBot.create(:digital_object_test_subclass, :with_sample_data) }
      let(:parent2) { FactoryBot.create(:digital_object_test_subclass, :with_sample_data) }

      it "triggers modification for an object's newly-added parent objects" do
        # Add children
        digital_object_with_sample_data.add_parent_uid(parent1.uid)
        digital_object_with_sample_data.add_parent_uid(parent2.uid)

        expect(digital_object_with_sample_data.save).to be(true)
        expect(digital_object_with_sample_data.errors).to be_empty
        expect(digital_object_with_sample_data.parent_uids).to eq(Set[parent1.uid, parent2.uid])

        # Retrieve latest copies of parents and verify that their structured children have been updated
        expect(DigitalObject::Base.find(parent1.uid).structured_children['structure']).to eq([digital_object_with_sample_data.uid])
        expect(DigitalObject::Base.find(parent1.uid).structured_children['structure']).to eq([digital_object_with_sample_data.uid])

        # Remove one child
        digital_object_with_sample_data.remove_parent_uid(parent2.uid)
        digital_object_with_sample_data.save
        expect(digital_object_with_sample_data.save).to be(true)
        expect(digital_object_with_sample_data.errors).to be_empty
        expect(digital_object_with_sample_data.parent_uids).to eq(Set[parent1.uid])

        # Retrieve latest copies of parents and verify that their structured children have been updated
        expect(DigitalObject::Base.find(parent1.uid).structured_children['structure']).to eq([digital_object_with_sample_data.uid])
        expect(DigitalObject::Base.find(parent2.uid).structured_children['structure']).to eq([])
      end
    end
  end

  context "#remove_all_parents" do
    let(:parent_digital_object_1) { FactoryBot.create(:digital_object_test_subclass) }
    let(:parent_digital_object_2) { FactoryBot.create(:digital_object_test_subclass) }
    let(:digital_object_with_parents) do
      obj = FactoryBot.create(:digital_object_test_subclass)
      obj.add_parent_uid(parent_digital_object_1.uid)
      obj.add_parent_uid(parent_digital_object_2.uid)
      obj.save
      obj
    end

    it "works as expected" do
      expect(digital_object_with_parents.parent_uids).to be_present
      digital_object_with_parents.remove_all_parents
      expect(digital_object_with_parents.parent_uids).to be_empty
    end
  end
end
