# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Hyacinth::DigitalObject::ResourceImport do
  let(:attributes) do
    {
      method: described_class::COPY,
      location: '/cool/file/path.txt',
      checksum: 'SHA256:e1266b81a70083fa5e3bf456239a1160fc6ebc179cdd71e458a9dd4bc7cc21f6',
      original_file_path: '/original/file/path.txt',
      media_type: 'text/plain',
      file_size: 100
    }
  end
  let(:arguments) { attributes.dup }
  let(:instance) { described_class.new(arguments) }

  describe "#initialize" do
    it "assigns attributes from arguments" do
      attributes.each do |attribute_name, value|
        expect(instance.send(attribute_name)).to eql(value)
      end
    end
  end

  describe "#valid?" do
    it "is valid with method and location" do
      expect(instance).to be_valid
    end

    it "is not valid without method" do
      instance.method = ''
      expect(instance).not_to be_valid
    end
    it "is not valid for invalid method value" do
      instance.method = :improvisational
      expect(instance).not_to be_valid
    end
    it "is not valid without location" do
      instance.location = ''
      expect(instance).not_to be_valid
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

    it "persists the imported content at dst_location" do
      pending('new implementation')
      instance.location = import_file.path
      instance.method = described_class::COPY
      instance.process_import_if_present(uid, resource_name, lock_object)
      expect(Hyacinth::Config.resource_storage.read(instance.dst_location)).to eql(example_content)
    end
  end
end
