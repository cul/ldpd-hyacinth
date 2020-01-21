# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Hyacinth::DigitalObject::Resource do
  let(:argument_names) { [:import_location, :import_method, :import_checksum, :location, :checksum, :original_filename, :file_size, :media_type] }
  let(:arguments) { argument_names.map { |s| [s.to_s, s.to_s] }.to_h }
  let(:attribute_names) { argument_names.select { |n| !n.to_s.starts_with?('import_') } }
  let(:attributes) { attribute_names.map { |s| [s.to_s, s.to_s] }.to_h }
  let(:instance) { described_class.new(arguments) }

  describe "#initialize" do
    it "assigns attributes from arguments" do
      argument_names.each do |attribute|
        expect(instance.send(attribute)).to eql(attribute.to_s)
      end
    end
  end

  describe "#to_serialized_form" do
    it { expect(instance.to_serialized_form).to eql(attributes) }
  end

  describe ".from_serialized_form" do
    before { instance.clear_import_data }
    let(:deserialized) { described_class.from_serialized_form(instance.to_serialized_form) }
    it "produces an object with identical attributes" do
      argument_names.each do |attribute|
        expect(instance.send(attribute)).to eql(deserialized.send(attribute))
      end
    end
  end

  describe "#has_valid_import?" do
    it "is valid with import_method and import_location" do
      expect(instance).to have_valid_import
    end

    it "is not valid without import_method" do
      instance.import_method = ''
      expect(instance).not_to have_valid_import
    end
    it "is not valid without import_location" do
      instance.import_location = ''
      expect(instance).not_to have_valid_import
    end
  end
  describe "#process_import_if_present" do
    let(:uid) { "testobject-1234" }
    let(:resource_name) { "rspecResource" }
    let(:lock_object) { Object.new }
    let(:example_content) { "Content to test import." }
    let(:import_file) do
      file = Tempfile.create(['rspecs', '.txt'])
      file.write(example_content)
      file.rewind
      file
    end

    it "persists the imported content" do
      instance.import_location = import_file.path
      instance.import_method = :copy
      instance.process_import_if_present(uid, resource_name, lock_object)
      expect(Hyacinth::Config.resource_storage.read(instance.location)).to eql(example_content)
    end
  end
end
