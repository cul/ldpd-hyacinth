# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Hyacinth::DigitalObject::Resource do
  let(:arguments) do
    {
      location: 'managed-disk:///path/to/file.txt',
      checksum: 'sha256:e1266b81a70083fa5e3bf456239a1160fc6ebc179cdd71e458a9dd4bc7cc21f6',
      original_file_path: '/some/original/path',
      media_type: 'text/plain',
      file_size: 123
    }
  end
  let(:attributes) { arguments.dup }
  let(:attribute_names) { arguments.keys }
  let(:instance) { described_class.new(arguments) }

  describe "#initialize" do
    it "assigns attributes" do
      attribute_names.each do |attribute|
        expect(instance.send(attribute)).to eql(attributes[attribute])
      end
    end

    it "defaults is_new to false" do
      expect(instance.is_new).to eq(false)
    end

    it "sets is_new to true when given an an opt" do
      expect(described_class.new(
        arguments.merge(is_new: true)
      ).is_new).to eq(true)
    end
  end

  describe "#to_serialized_form" do
    it "has the correct form" do
      expect(instance.to_serialized_form).to eql(attributes.stringify_keys)
    end
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
