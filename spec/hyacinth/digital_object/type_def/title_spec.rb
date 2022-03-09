# frozen_string_literal: true

require 'rails_helper'

describe Hyacinth::DigitalObject::TypeDef::Title do
  let(:type_def) { described_class.new }
  let(:untagged_title) { { 'value' => untagged_title_value } }
  let(:untagged_title_value) do
    {
      'non_sort_portion' => 'The',
      'sort_portion' => 'Best Item Ever'
    }
  end
  context "typical values with no lang tag" do
    it "round trips" do
      expect(type_def.to_serialized_form(untagged_title)).to eql(untagged_title)
      expect(type_def.from_serialized_form(untagged_title)).to eql(untagged_title)
    end
  end
  context "with extraneous data" do
    let(:extra_values) { { 'extra' => ['data'] } }
    let(:given_values) { untagged_title.merge(extra_values) }
    it "filters out extraneous data in to_serialized_form" do
      expect(given_values).to include(extra_values)
      expect(type_def.to_serialized_form(given_values)).not_to include(extra_values)
    end
    it "passes serialized data back as written" do
      expect(given_values).to include(extra_values)
      expect(type_def.from_serialized_form(given_values)).to include(given_values)
    end
  end
  context "with nillable data" do
    let(:non_whitespace_values) { { 'sort_portion' => 'Present', 'non_sort_portion' => 'A ' } }
    let(:whitespace_property) { 'non_sort_portion' }
    let(:whitespace_values) { non_whitespace_values.merge(whitespace_property => '  ') }
    let(:all_whitespace_values) { non_whitespace_values.transform_values { |_v| ' ' } }
    it "strips blank values before storing" do
      expect(type_def.to_serialized_form('value' => whitespace_values).fetch('value')).not_to include(whitespace_property)
    end
    it "nils completely blank hashes before storing" do
      expect(type_def.to_serialized_form('value' => all_whitespace_values)).to be_nil
      expect(type_def.to_serialized_form({})).to be_nil
    end
  end
  context "with lang tag" do
    include_context 'with english-adjacent language subtags'
    let(:given_values) { untagged_title.merge('value_lang' => { 'tag' => lang }) }
    context "in a canonical form" do
      let(:lang) { 'en' }
      it "round-trips a canonical tag" do
        expect(type_def.to_serialized_form(given_values)).to include('value_lang' => { 'tag' => lang })
      end
    end
    context "that has a preferred value" do
      let(:lang) { 'en-Latn' }
      it "round-trips a canonical tag" do
        expect(type_def.to_serialized_form(given_values)).to include('value_lang' => { 'tag' => 'en' })
      end
    end
  end
end
