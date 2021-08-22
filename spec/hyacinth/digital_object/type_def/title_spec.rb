# frozen_string_literal: true

require 'rails_helper'

describe Hyacinth::DigitalObject::TypeDef::Title do
  let(:type_def) { described_class.new }
  let(:untagged_title) do
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
  context "with lang tag" do
    let(:iana_en_fixture) { file_fixture('files/iana_language/english-subtag-registry') }
    before do
      Hyacinth::Language::SubtagLoader.new(iana_en_fixture).load
    end
    let(:given_values) { untagged_title.merge('lang' => lang) }
    context "in a canonical form" do
      let(:lang) { 'en' }
      it "round-trips a canonical tag" do
        expect(type_def.to_serialized_form(given_values)).to include('lang' => { 'tag' => lang })
      end
    end
    context "that has a preferred value" do
      let(:lang) { 'en-Latn' }
      it "round-trips a canonical tag" do
        expect(type_def.to_serialized_form(given_values)).to include('lang' => { 'tag' => 'en' })
      end
    end
  end
end
