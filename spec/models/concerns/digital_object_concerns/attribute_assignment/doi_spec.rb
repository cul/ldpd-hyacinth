# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DigitalObjectConcerns::AttributeAssignment::Doi do
  include_context 'with stubbed search adapters'
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

  describe "#assign_doi" do
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

  describe "#assign_mint_doi" do
    context "when no doi has been set, it sets @mint_doi to the given value, converted to a boolean value" do
      {
        true => true,
        false => false,
        'true' => true,
        'false' => false,
        'TRUE' => true,
        'FALSE' => false
      }.each do |value_to_set, expected_result|
        it "converts as expected for #{value_to_set.inspect}" do
          expect(digital_object.instance_variable_get('@mint_doi')).to eq(false)
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
  describe "#ensure_doi_if_requested" do
    let(:mint_doi) { true }
    before { digital_object_with_doi.mint_doi = mint_doi }
    context "when a doi has already been set" do
      it "does not call ensure_doi in save hook" do
        expect(Hyacinth::Config.external_identifier_adapter).not_to receive(:mint)
        digital_object_with_doi.save
        expect(digital_object_with_doi.mint_doi).to be false
      end
    end
    context "when a doi has not been set" do
      context "and @mint_doi is false" do
        it "does not call ensure_doi in save hook" do
          expect(digital_object).not_to receive(:ensure_doi)
          digital_object.save
          expect(digital_object.mint_doi).to be false
        end
      end
      context "and @mint_doi is true" do
        it "calls ensure_doi in save hook" do
          expect(digital_object).not_to receive(:ensure_doi)
          digital_object.save
          expect(digital_object.mint_doi).to be false
        end
      end
    end
  end
end
