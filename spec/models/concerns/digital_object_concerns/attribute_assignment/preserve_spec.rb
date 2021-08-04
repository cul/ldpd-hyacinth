# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DigitalObjectConcerns::AttributeAssignment::Preserve do
  let(:digital_object) { FactoryBot.build(:digital_object_test_subclass) }
  let(:preservation_target_uris) { ['preservation:target/uri'] }
  let(:digital_object_data_with_target_uris) do
    {
      'preservation_target_uris' => preservation_target_uris
    }
  end
  let(:digital_object_data_with_different_target_uris) do
    {
      'preservation_target_uris' => ['preservation:different/uri']
    }
  end
  let(:digital_object_with_target_uris) do
    dobj = FactoryBot.build(:digital_object_test_subclass)
    dobj.assign_preservation_target_uris(digital_object_data_with_target_uris)
    dobj
  end

  context "#assign_preservation_target_uris" do
    context "when no preservation target uris have been set" do
      it "sets the preservation target uris" do
        digital_object.assign_preservation_target_uris(digital_object_data_with_target_uris)
        expect(digital_object.preservation_target_uris.to_a).to eq(preservation_target_uris)
      end
    end

    context "when preservation target uris have already been set" do
      it "raises an error if a different value is supplied" do
        expect { digital_object_with_target_uris.assign_preservation_target_uris(digital_object_data_with_different_target_uris) }.to raise_error(Hyacinth::Exceptions::AlreadySet)
      end

      it "does not raise an error if the existing value is supplied" do
        expect { digital_object_with_target_uris.assign_preservation_target_uris(digital_object_data_with_target_uris) }.not_to raise_error
      end

      it "does not clear the preservation target uris when digital object data with no preservation_target_uris key is supplied" do
        digital_object_with_target_uris.assign_preservation_target_uris({})
        expect(digital_object_with_target_uris.preservation_target_uris.to_a).to eq(preservation_target_uris)
      end
    end
  end
end
