# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DigitalObjectConcerns::MetadataStorageSerialization do
  let!(:digital_object) do
    obj = FactoryBot.create(:digital_object_test_subclass)
    obj.resources['test_resource1'] = Hyacinth::DigitalObject::Resource.new(
      location: 'managed-disk:///path/to/file1',
      checksum: 'sha256:717f2c6ffbd649cd57ecc41ac6130c3b6210f1473303bcd9101a9014551bffb2'
    )
    obj.resources['test_resource2'] = Hyacinth::DigitalObject::Resource.new(
      location: 'managed-disk:///path/to/file2',
      checksum: 'sha256:30a7b320463d2d4a2052b72ea48518f5ad36dcb935b54628f292861241a7632e'
    )
    obj.save
    obj
  end

  let(:expected_metadata_storage_json) do
    {
      'uid' => digital_object.uid,
      'serialization_version' => 2,
      'metadata' => {
        'custom_field1' => 'custom default value 1',
        'custom_field2' => 'custom default value 2',
        'primary_project' => { 'string_key' => 'great_project' },
        'other_projects' => [],
        'preservation_target_uris' => [],
        'descriptive_metadata' => {},
        'identifiers' => [],
        'rights' => {}
      },
      'resources' => {
        'test_resource1' => {
          'location' => 'managed-disk:///path/to/file1',
          'checksum' => 'sha256:717f2c6ffbd649cd57ecc41ac6130c3b6210f1473303bcd9101a9014551bffb2',
          'media_type' => nil,
          'original_file_path' => nil,
          'file_size' => nil
        },
        'test_resource2' => {
          'location' => 'managed-disk:///path/to/file2',
          'checksum' => 'sha256:30a7b320463d2d4a2052b72ea48518f5ad36dcb935b54628f292861241a7632e',
          'media_type' => nil,
          'original_file_path' => nil,
          'file_size' => nil
        }
      }
    }
  end

  context "#as_metadata_storage_json" do
    it "returns a Hash with all defined metadata_attribute keys and values, and a 'resources' key with the expected value" do
      expect(digital_object.send(:as_metadata_storage_json)).to eq(expected_metadata_storage_json)
    end
  end

  context "#write_fields_to_metadata_storage" do
    it "writes the expected value" do
      expect(Hyacinth::Config.metadata_storage).to receive(:write) do |_location_uri, json_string|
        expect(JSON.parse(json_string)).to eq(expected_metadata_storage_json)
      end
      digital_object.write_fields_to_metadata_storage
    end
  end

  context "#load_fields_from_metadata_storage" do
    it "deserializes as expected" do
      digital_object.metadata_attributes.map do |metadata_attribute_name, type_def|
        expect(digital_object).to receive("#{metadata_attribute_name}=").with(type_def.from_serialized_form(expected_metadata_storage_json['metadata'][metadata_attribute_name.to_s]))
      end
      digital_object.resource_attribute_names.map do |resource_attribute_name|
        expect(digital_object.resources).to receive(:[]=).with(resource_attribute_name.to_s, Hyacinth::DigitalObject::Resource)
      end
      digital_object.load_fields_from_metadata_storage
    end
  end
end
