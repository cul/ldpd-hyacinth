require 'rails_helper'

RSpec.describe DigitalObjectConcerns::Serializer do
  let(:digital_object_with_sample_data) { FactoryBot.build(:digital_object_test_subclass, :with_sample_data) }

  before {
    allow(digital_object_with_sample_data).to receive(:metadata_attributes).and_return({
      'uid' => Hyacinth::DigitalObject::TypeDef::String.new,
      'group' => Hyacinth::DigitalObject::TypeDef::Group.new
    })
    allow(digital_object_with_sample_data).to receive(:uid).and_return('unique-id-123')
    allow(digital_object_with_sample_data).to receive(:group).and_return(FactoryBot.build(:group))

    allow(digital_object_with_sample_data).to receive(:resource_attributes).and_return({
      'resource1' => Hyacinth::DigitalObject::Resource.new(location: 'disk:///path/to/file1', checksum: 'SHA256:e1266b81a70083fa5e3bf456239a1160fc6ebc179cdd71e458a9dd4bc7cc21f6'),
      'resource2' => Hyacinth::DigitalObject::Resource.new(location: 'disk:///path/to/file2', checksum: 'SHA256:30a7b320463d2d4a2052b72ea48518f5ad36dcb935b54628f292861241a7632e')
    })
  }

  context "#to_serialized_form" do
    let (:serialized_data) { digital_object_with_sample_data.to_serialized_form }

    it "returns a Hash with keys for all defined metadata_attributes, and a 'resources' key with the expected value" do
      expect(digital_object_with_sample_data.to_serialized_form).to eq({
        'uid' => 'unique-id-123',
        'group' => {
          'string_key' => 'developers'
        },
        'resources' => {
          'resource1' => {
            'location' => 'disk:///path/to/file1',
            'checksum' => 'SHA256:e1266b81a70083fa5e3bf456239a1160fc6ebc179cdd71e458a9dd4bc7cc21f6'
          },
          'resource2' => {
            'location' => 'disk:///path/to/file2',
            'checksum' => 'SHA256:30a7b320463d2d4a2052b72ea48518f5ad36dcb935b54628f292861241a7632e'
          },
        }
      })
    end
  end
end
