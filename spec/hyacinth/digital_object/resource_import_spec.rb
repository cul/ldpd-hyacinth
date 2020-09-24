# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Hyacinth::DigitalObject::ResourceImport do
  let(:file_copy_attributes) do
    {
      method: described_class::COPY,
      location: Rails.root.join('spec', 'fixtures', 'files', 'test.txt').to_s,
      checksum: 'sha256:e1266b81a70083fa5e3bf456239a1160fc6ebc179cdd71e458a9dd4bc7cc21f6',
      original_file_path: '/original/file/path.txt',
      media_type: 'text/plain',
      file_size: 100
    }
  end
  let(:file_copy_arguments) { file_copy_attributes.dup }
  let(:file_copy_instance) { described_class.new(file_copy_arguments) }

  let(:file_track_instance) { described_class.new(file_copy_arguments.merge(method: described_class::TRACK)) }

  let(:blob) do
    blob_content = "Run, don't walk from...the blob!"
    blob = ActiveStorage::Blob.create_before_direct_upload!(
      filename: 'blobfile.txt',
      byte_size: blob_content.bytesize,
      checksum: Digest::MD5.base64digest(blob_content),
      content_type: 'text/plain'
    )
    blob.upload(StringIO.new(blob_content))
    blob
  end
  let(:blob_copy_attributes) do
    {
      method: described_class::COPY,
      location: blob,
      checksum: 'sha256:c72a7eb71263aa3e8936049a925556881c4f9e562dcdc1cae036b11579dfa175',
      original_file_path: '/original/file/path.txt',
      media_type: 'text/plain',
      file_size: 32
    }
  end
  let(:blob_copy_arguments) { blob_copy_attributes.dup }
  let(:blob_copy_instance) { described_class.new(blob_copy_arguments) }

  describe "#initialize" do
    it "assigns attributes from arguments" do
      file_copy_attributes.each do |attribute_name, value|
        expect(file_copy_instance.send(attribute_name)).to eql(value)
      end
    end
  end

  describe "#valid?" do
    it "is valid with method and location" do
      expect(file_copy_instance).to be_valid
    end

    it "is valid for a blob location" do
      expect(blob_copy_instance).to be_valid
    end

    it "is not valid without method" do
      file_copy_instance.method = ''
      expect(file_copy_instance).not_to be_valid
    end
    it "is not valid for invalid method value" do
      file_copy_instance.method = :improvisational
      expect(file_copy_instance).not_to be_valid
    end
    it "is not valid without location" do
      file_copy_instance.location = ''
      expect(file_copy_instance).not_to be_valid
    end
  end

  describe "#location_is_active_storage_blob?" do
    it "returns true when location is a blob" do
      expect(blob_copy_instance.location_is_active_storage_blob?).to eq(true)
    end

    it "returns false when location is not a blob" do
      expect(file_copy_instance.location_is_active_storage_blob?).to eq(false)
    end
  end

  describe "#download" do
    let(:downloaded_content) do
      io = StringIO.new
      resource_import_instance.download { |chunk| io << chunk }
      io.rewind
      io.read
    end
    context "works for a blob location" do
      let(:resource_import_instance) { blob_copy_instance }
      it { expect(downloaded_content).to eq("Run, don't walk from...the blob!") }
    end

    context "works for a non-blob location" do
      let(:resource_import_instance) { file_copy_instance }
      it { expect(downloaded_content).to eq('What a great test file!') }
    end
  end

  describe "#method_copy?" do
    it "returns true for copy method" do
      expect(file_copy_instance.method_copy?).to eq(true)
    end

    it "returns false for non-copy method" do
      expect(file_track_instance.method_copy?).to eq(false)
    end
  end

  describe "#hexgidest_from_checksum" do
    it "extracts the expected value" do
      expect(file_copy_instance.hexgidest_from_checksum).to eq('e1266b81a70083fa5e3bf456239a1160fc6ebc179cdd71e458a9dd4bc7cc21f6')
    end

    it "returns nil when checksum is blank" do
      file_copy_instance.checksum = nil
      expect(file_copy_instance.hexgidest_from_checksum).to eq(nil)
      file_copy_instance.checksum = ''
      expect(file_copy_instance.hexgidest_from_checksum).to eq(nil)
    end

    it "raises an exception if the provided checksum is not a valid sha256-format checksum" do
      file_copy_instance.checksum = 'nah256:abcdefg'
      expect { file_copy_instance.hexgidest_from_checksum }.to raise_error(Hyacinth::Exceptions::InvalidChecksumFormatError)
    end
  end

  describe "#media_type_for_filename" do
    before { allow(file_copy_instance).to receive(:preferred_original_file_path).and_return('/some/path/to/file.jpg') }
    it "returns the expected value" do
      expect(file_copy_instance.media_type_for_filename).to eq('image/jpeg')
    end
  end

  describe "#preferred_original_file_path" do
    it "returns the specifically set original file path if given" do
      expect(file_copy_instance.preferred_original_file_path).to eq('/original/file/path.txt')
    end

    it "for a blob, uses a blob's filename value if an original file path was not given" do
      blob_copy_instance.original_file_path = nil
      expect(blob_copy_instance.preferred_original_file_path).to eq(blob_copy_instance.location.filename.to_s)
    end

    it "for a non-blob, falls back to the location value if an original file path was not given" do
      file_copy_instance.original_file_path = nil
      expect(file_copy_instance.preferred_original_file_path).to eq(file_copy_instance.location)
    end
  end
end