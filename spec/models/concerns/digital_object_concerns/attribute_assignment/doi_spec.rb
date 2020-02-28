# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DigitalObjectConcerns::AttributeAssignment::Doi do
  let(:digital_object) { FactoryBot.build(:digital_object_test_subclass) }
  let(:doi) { 'abc/123' }
  let(:digital_object_data_with_doi) do
    {
      'doi' => doi
    }
  end
  let(:digital_object_data_with_different_doi) do
    {
      'doi' => 'different/doi'
    }
  end
  let(:digital_object_with_doi) do
    dobj = FactoryBot.build(:digital_object_test_subclass)
    dobj.assign_doi(digital_object_data_with_doi)
    dobj
  end

  context "#assign_doi" do
    context "when no doi has been set" do
      it "sets the doi" do
        digital_object.assign_doi(digital_object_data_with_doi)
        expect(digital_object.doi).to eq(doi)
      end
    end

    context "when a doi has already been set" do
      it "raises an error if a different value is supplied" do
        expect { digital_object_with_doi.assign_doi(digital_object_data_with_different_doi) }.to raise_error(Hyacinth::Exceptions::AlreadySet)
      end

      it "does not raise an error if the existing value is supplied" do
        expect { digital_object_with_doi.assign_doi(digital_object_data_with_doi) }.not_to raise_error
      end

      it "does not clear the doi when digital object data with no doi key is supplied" do
        digital_object_with_doi.assign_doi({})
        expect(digital_object_with_doi.doi).to eq(doi)
      end
    end
  end

  context "#assign_mint_doi" do
    context "when no doi has been set" do
      it "sets @mint_doi to the given value, converted to a boolean value" do
        expect(digital_object.instance_variable_get('@mint_doi')).to eq(false)
        {
          true => true,
          false => false,
          'true' => true,
          'false' => false,
          'TRUE' => true,
          'FALSE' => false
        }.each do |value_to_set, expected_result|
          digital_object.assign_mint_doi('mint_doi' => value_to_set)
          expect(digital_object.instance_variable_get('@mint_doi')).to eq(expected_result)
        end
      end
    end

    context "when a doi has already been set" do
      it "always keeps a false value for @mint_doi" do
        expect(digital_object_with_doi.instance_variable_get('@mint_doi')).to eq(false)
        digital_object_with_doi.assign_mint_doi('mint_doi' => true)
        expect(digital_object_with_doi.instance_variable_get('@mint_doi')).to eq(false)
      end
    end
  end
end
