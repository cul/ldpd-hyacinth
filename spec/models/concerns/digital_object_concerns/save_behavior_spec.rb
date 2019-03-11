require 'rails_helper'

RSpec.describe DigitalObjectConcerns::SaveBehavior do
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
      expect(digital_object_with_sample_data.save).to eq(true)
      expect(digital_object_with_sample_data.errors.empty?).to eq(true)
    end

    it "returns false when an invalid object fails to save, and adds errors to #errors array" do
      digital_object_with_sample_data.state = 'invalid state'
      expect(digital_object_with_sample_data.save).to eq(false)
      expect(digital_object_with_sample_data.errors).to be_present
      expect(digital_object_with_sample_data.errors.include?(:state)).to eq(true)
    end

    context "with added parents" do
      [:mock_parent_object1, :mock_parent_object2].each do |var|
        let(var) {
          double(DigitalObject::TestSubclass)
        }
      end
      let(:uid) { 'uid-123' }
      before {
        allow(DigitalObject::Base).to receive(:find).with('parent-111').and_return(mock_parent_object1)
        allow(DigitalObject::Base).to receive(:find).with('parent-222').and_return(mock_parent_object2)
        allow(Hyacinth.config.search_adapter).to receive(:index)
        allow_any_instance_of(digital_object_with_sample_data.class).to receive(:mint_uid).and_return(uid)
        digital_object_with_sample_data.instance_variable_set('@parent_uids', Set['parent-111', 'parent-222'])
      }
      it "triggers modification for an object's newly-added parent objects" do
        expect(mock_parent_object1).to receive(:append_child_digital_object_uid).with(uid)
        expect(mock_parent_object1).to receive(:deep_copy_of_structured_children)
        expect(mock_parent_object1).to receive(:save)
        expect(mock_parent_object2).to receive(:append_child_digital_object_uid).with(uid)
        expect(mock_parent_object2).to receive(:deep_copy_of_structured_children)
        expect(mock_parent_object2).to receive(:save)

        expect(digital_object_with_sample_data.save).to be(true)
        expect(digital_object_with_sample_data.errors).to be_empty
      end
    end
  end
end
