require 'rails_helper'

RSpec.describe DigitalObjectConcerns::SaveBehavior do
  context "#save" do
    let(:valid_object) {
      obj = FactoryBot.build(:digital_object_test_subclass_with_complex_data)
      obj
    }
    let(:invalid_object) {
      obj = FactoryBot.build(:digital_object_test_subclass_with_complex_data)
      obj.state = 'invalid state'
      obj
    }

    context "#flat_child_uid_set" do
      it "works as expected for a flat sequence" do
        allow(valid_object).to receive(:structured_children).and_return({
          'type' => 'sequence',
          'structure' => ['child-111', 'child-222', 'child-333']
        })
        expect(valid_object.flat_child_uid_set).to eq(Set['child-111', 'child-222', 'child-333'])
      end
    end

    context "#save" do
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
      }
      it "runs as expected, returning true when a valid object is saved successfully, and doesn't have any errors in the #errors array" do
        allow_any_instance_of(valid_object.class).to receive(:mint_uid).and_return(uid)

        expect(mock_parent_object1).to receive(:append_child_digital_object_uid).with(uid)
        expect(mock_parent_object1).to receive(:deep_copy_of_structured_children)
        expect(mock_parent_object1).to receive(:save)
        expect(mock_parent_object2).to receive(:append_child_digital_object_uid).with(uid)
        expect(mock_parent_object2).to receive(:deep_copy_of_structured_children)
        expect(mock_parent_object2).to receive(:save)

        expect(valid_object.save).to be(true)
        expect(valid_object.errors).to be_empty
      end

      it "returns false when a valid object fails to save, and adds errors to #errors array" do
        expect(invalid_object.save).to eq(false)
        expect(invalid_object.errors).to be_present
        expect(invalid_object.errors.include?(:state)).to eq(true)
      end
    end
  end
end
