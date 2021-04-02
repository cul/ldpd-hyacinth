# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Hyacinth::DigitalObject::Resource do
  let(:arguments) do
    {
      location: 'managed-disk:///path/to/file.txt',
      checksum: 'sha256:717f2c6ffbd649cd57ecc41ac6130c3b6210f1473303bcd9101a9014551bffb2',
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

  describe '#image?' do
    it 'returns true for an image resource' do
      expect(FactoryBot.build(:resource, :image).image?).to eq(true)
    end
    it 'returns false for a non-image resource' do
      expect(FactoryBot.build(:resource, :text).image?).to eq(false)
    end
  end

  describe '#video?' do
    it 'returns true for a video resource' do
      expect(FactoryBot.build(:resource, :video).video?).to eq(true)
    end
    it 'returns false for a non-video resource' do
      expect(FactoryBot.build(:resource, :text).video?).to eq(false)
    end
  end

  describe '#audio?' do
    it 'returns true for an audio resource' do
      expect(FactoryBot.build(:resource, :audio).audio?).to eq(true)
    end
    it 'returns false for a non-audio resource' do
      expect(FactoryBot.build(:resource, :text).audio?).to eq(false)
    end
  end

  describe '#pdf?' do
    it 'returns true for a pdf resource' do
      expect(FactoryBot.build(:resource, :pdf).pdf?).to eq(true)
    end
    it 'returns false for a non-pdf resource' do
      expect(FactoryBot.build(:resource, :text).pdf?).to eq(false)
    end
  end

  describe '#text_or_office_document?' do
    it 'returns true for a text or office document resource' do
      expect(FactoryBot.build(:resource, :text).text_or_office_document?).to eq(true)
      expect(FactoryBot.build(:resource, :office_document).text_or_office_document?).to eq(true)
    end
    it 'returns false for a non-text and non-office-document resource' do
      expect(FactoryBot.build(:resource, :image).text_or_office_document?).to eq(false)
    end
  end
end
