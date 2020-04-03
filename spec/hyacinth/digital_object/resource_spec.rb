# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Hyacinth::DigitalObject::Resource do
  let(:attribute_names) { [:location, :checksum, :original_file_path, :media_type, :file_size] }
  let(:arguments) { attribute_names.map { |s| [s.to_s, s.to_s] }.to_h }
  let(:attributes) { attribute_names.map { |s| [s.to_s, s.to_s] }.to_h }
  let(:instance) { described_class.new(arguments) }

  describe "#initialize" do
    it "assigns attributes" do
      attribute_names.each do |attribute|
        expect(instance.send(attribute)).to eql(attribute.to_s)
      end
    end
  end

  describe "#to_serialized_form" do
    it { expect(instance.to_serialized_form).to eql(attributes) }
  end

  describe ".from_serialized_form" do
    let(:deserialized) { described_class.from_serialized_form(instance.to_serialized_form) }
    it "produces an object with identical attributes" do
      attribute_names.each do |attribute|
        expect(instance.send(attribute)).to eql(deserialized.send(attribute))
      end
    end
  end
end
