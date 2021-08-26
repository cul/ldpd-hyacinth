# frozen_string_literal: true

require 'rails_helper'

describe Hyacinth::DigitalObject::TypeDef::Language do
  let(:type_def) { described_class.new }
  include_context 'with english-adjacent language subtags'
  let(:use_preferred) { false }
  let(:json_var) { type_def.to_serialized_form(tag) }

  context "a tag is the canonical/preferred value" do
    let(:tag) { 'en' }
    it "round-trips a canonical tag" do
      expect(json_var).to include('tag' => 'en')
      expect(type_def.from_serialized_form(json_var)).to eql tag
    end
  end
  context "a tag has a preferred value" do
    let(:tag) { 'en-Latn' }
    it "round-trips a canonical tag" do
      expect(json_var).to include('tag' => 'en')
      expect(type_def.from_serialized_form(json_var)).to eql 'en'
    end
  end
end
