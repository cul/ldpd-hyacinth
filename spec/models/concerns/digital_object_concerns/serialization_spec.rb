# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DigitalObjectConcerns::Serialization do
  let(:digital_object_with_sample_data) do
    obj = FactoryBot.build(:digital_object_test_subclass, :with_sample_data)
    obj.instance_variable_set :@uid, 'unique-id-123'
    obj.resources['test_resource1'] = Hyacinth::DigitalObject::Resource.new(location: 'disk:///path/to/file1', checksum: 'SHA256:e1266b81a70083fa5e3bf456239a1160fc6ebc179cdd71e458a9dd4bc7cc21f6')
    obj.resources['test_resource2'] = Hyacinth::DigitalObject::Resource.new(location: 'disk:///path/to/file2', checksum: 'SHA256:30a7b320463d2d4a2052b72ea48518f5ad36dcb935b54628f292861241a7632e')
    obj
  end

  let(:expected_serialized_form) do
    {
      'serialization_version' => DigitalObject::Base::SERIALIZATION_VERSION,
      'digital_object_type' => 'test_subclass',
      'uid' => 'unique-id-123',
      'resources' => {
        'test_resource1' => {
          'location' => 'disk:///path/to/file1',
          'checksum' => 'SHA256:e1266b81a70083fa5e3bf456239a1160fc6ebc179cdd71e458a9dd4bc7cc21f6',
          'original_filename' => nil,
          'file_size' => nil
        },
        'test_resource2' => {
          'location' => 'disk:///path/to/file2',
          'checksum' => 'SHA256:30a7b320463d2d4a2052b72ea48518f5ad36dcb935b54628f292861241a7632e',
          'original_filename' => nil,
          'file_size' => nil
        },
      }
    }
  end

  context "#to_serialized_form" do
    before do
      allow(digital_object_with_sample_data).to receive(:metadata_attributes).and_return({
        'serialization_version' => Hyacinth::DigitalObject::TypeDef::String.new,
        'digital_object_type' => Hyacinth::DigitalObject::TypeDef::String.new,
        'uid' => Hyacinth::DigitalObject::TypeDef::String.new
      })
      allow(digital_object_with_sample_data).to receive(:uid).and_return('unique-id-123')
      allow(digital_object_with_sample_data).to receive(:serialization_version).and_return(DigitalObject::Base::SERIALIZATION_VERSION)
      allow(digital_object_with_sample_data).to receive(:digital_object_type).and_return('test_subclass')
    end
    it "returns a Hash with keys for all defined metadata_attributes, and a 'resources' key with the expected value" do
      expect(digital_object_with_sample_data.to_serialized_form).to include(expected_serialized_form)
    end
  end

  context ".from_serialized_form" do
    let(:digital_object_record) { digital_object_with_sample_data.digital_object_record }
    let(:deserialized_instance) { digital_object_with_sample_data.class.from_serialized_form(digital_object_record, expected_serialized_form) }
    it "deserializes as expected" do
      expect(deserialized_instance).to be_a(DigitalObject::TestSubclass)
      expect(deserialized_instance.to_serialized_form).to include(expected_serialized_form)
    end
  end
end
