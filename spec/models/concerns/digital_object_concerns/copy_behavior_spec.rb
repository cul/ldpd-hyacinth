# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DigitalObjectConcerns::CopyBehavior do
  let(:digital_object_with_sample_data) { FactoryBot.build(:digital_object_test_subclass, :with_sample_data) }

  context "#deep_copy" do
    let(:copy) { digital_object_with_sample_data.deep_copy }
    it "returns a copy of the instance with the same values, but not the same instances of those values" do
      # Make sure the object isn't a copy by reference
      expect(digital_object_with_sample_data.digital_object_record).not_to equal(copy.digital_object_record)

      # Check one of the fields to make sure it's a copy by value, but not a copy by identify
      expect(digital_object_with_sample_data.descriptive_metadata).to eq(copy.descriptive_metadata)
      expect(digital_object_with_sample_data.descriptive_metadata).not_to equal(copy.descriptive_metadata)
    end
  end

  context "#deep_copy_instance_variables_from" do
    let(:new_instance_with_copied_vars) do
      new_instance = digital_object_with_sample_data.class.new
      new_instance.deep_copy_instance_variables_from(digital_object_with_sample_data)
      new_instance
    end
    it "copies instance variables as expected" do
      digital_object_with_sample_data.instance_variables.each do |instance_variable|
        original_var = digital_object_with_sample_data.instance_variable_get(instance_variable)
        copy_var = new_instance_with_copied_vars.instance_variable_get(instance_variable)

        if original_var.is_a?(DigitalObjectRecord) && original_var.new_record?
          # New DigitalObjectRecord objects aren't considered equal by value or identity.
          expect(
            copy_var
          ).not_to eq(
            original_var
          )

          expect(
            copy_var
          ).not_to equal(
            original_var
          )
        else
          # We expect the copy to have the same value as the original
          expect(
            copy_var
          ).to eq(
            original_var
          )
          if [TrueClass, FalseClass].include?(original_var.class)
            # TrueClass and FalseClass instances are always identity equal (they have the same object_id)
            expect(
              copy_var
            ).to equal(
              original_var
            )
          else
            # We expect the copy to not be identity equal to the original (it has a different object_id)
            expect(
              copy_var
            ).not_to equal(
              original_var
            )
          end
        end
      end
    end
  end

  context "#deep_copy_metadata_attributes_from" do
    let(:new_instance) do
      digital_object_with_sample_data.class.new
    end

    let(:invalid_metadata_attribute_names) { [:fake_field1, :fake_field2] }
    let(:valid_metadata_attribute_names) { [:state, :doi] }

    it "raises an error if an invalid metadata attribute is given" do
      expect { new_instance.deep_copy_metadata_attributes_from(digital_object_with_sample_data, invalid_metadata_attribute_names) }.to raise_error(ArgumentError)
    end

    it "copies as expected when valid attributes are given" do
      digital_object_with_sample_data.send(:state=, 'deleted')
      digital_object_with_sample_data.send(:doi=, 'ABC/12345')
      new_instance.deep_copy_metadata_attributes_from(digital_object_with_sample_data, valid_metadata_attribute_names)

      # We copied state, so values should be the same
      expect(new_instance.state).to eq(digital_object_with_sample_data.state)
      expect(new_instance.state).not_to equal(digital_object_with_sample_data.state)

      # We copied doi, so values should be the same
      expect(new_instance.doi).to eq(digital_object_with_sample_data.doi)
      expect(new_instance.doi).not_to equal(digital_object_with_sample_data.doi)

      # We didn't copy descriptive_metadata, so values shouldn't be the same
      expect(new_instance.descriptive_metadata).not_to eq(digital_object_with_sample_data.descriptive_metadata)
    end

  end
end
