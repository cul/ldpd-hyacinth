require 'rails_helper'
require 'shared_contexts/digital_object/example_shared_subclass'

RSpec.describe DigitalObject::Base, type: :model do
  it "cannot be instantiated" do
    expect { described_class.new }.to raise_error(NotImplementedError)
  end

  context "subclass instance" do
    include_context 'sample digital_object_subclass and digital_object_subclass_instance'

    it "can be subclassed" do
      expect(digital_object_subclass).to be_a(Class)
    end

    context "a new subclass instance" do
      it "can be instantiated" do
        expect { digital_object_subclass.new }.not_to raise_error
      end

      it "has the expected defaults for all attributes" do
        allow_any_instance_of(Hyacinth::DigitalObject::Types).to receive(:class_to_key).with(digital_object_subclass).and_return('digital_object_subclass')
        datetime = DateTime.now
        allow(DateTime).to receive(:now).and_return(datetime) # Return

        expect(digital_object_subclass_instance.metadata_attributes.reduce({}) do |hsh, (attribute_name, _attribute)|
          hsh[attribute_name] = digital_object_subclass_instance.send(attribute_name)
          hsh
        end).to eq(
          {
            uid: nil,
            doi: nil,
            digital_object_type: 'digital_object_subclass',
            state: 'active',
            created_by: nil,
            updated_by: nil,
            last_published_by: nil,
            created_at: datetime,
            updated_at: datetime,
            published_at: nil,
            first_published_at: nil,
            persisted_to_preservation_at: nil,
            first_persisted_to_preservation_at: nil,
            group: nil,
            projects: [],
            publish_targets: [],
            parent_uids: Set.new,
            structured_child_uids: {},
            dynamic_field_data: {},
            preservation_persistence_data: {},
            custom_field: 'custom default value'
          }
        )
      end

      it "has the expected resources based on what is defined in the class" do
        expect(digital_object_subclass_instance.resource_attributes.keys.sort).to eq([:test_resource1, :test_resource2])
      end

      context "#new_record?" do
        it "returns true for a newly created instance" do
          expect(digital_object_subclass_instance.new_record?).to eq(true)
        end

        it "returns false for a persisted instance" do
          skip
        end
      end

      context "#digital_object_record" do
        it "returns the underlying digital_object_record" do
          expect(digital_object_subclass_instance.digital_object_record).to be_a(DigitalObjectRecord)
        end
      end

      context "#optimistic_lock_token and #optimistic_lock_token=" do
        let(:token) { SecureRandom.uuid }
        it "can be set" do
          digital_object_subclass_instance.optimistic_lock_token = token
          expect(digital_object_subclass_instance.optimistic_lock_token).to eq(token)
        end
      end
    end
  end

  context "shared examples for included modules" do
    include_examples 'DigitalObjectConcerns::DigitalObjectData::Serializer'
  end
end
