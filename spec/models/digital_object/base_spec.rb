require 'rails_helper'

RSpec.describe DigitalObject::Base, type: :model do
  # we create a subclass instance for testing because this class is
  # designed to be abstract and cannot be instantiated
  let(:instance) { described_class.new }
  let(:subclass) do
    Class.new(described_class) do
      resource_attribute :test_resource1
      resource_attribute :test_resource2
    end
  end
  let(:subclass_instance) { subclass.new }

  it "cannot be instantiated" do
    expect { described_class.new }.to raise_error(NotImplementedError)
  end

  it "can be subclassed" do
    expect(subclass).to be_a(Class)
  end

  context "subclass instance" do
    it "can be instantiated" do
      expect { subclass.new }.not_to raise_error
    end

    it "has the expected defaults for all attributes" do
      allow_any_instance_of(Hyacinth::DigitalObject::Types).to receive(:class_to_key).with(subclass).and_return('test_subclass')

      expect(subclass_instance.uid).to eq(nil)
      expect(subclass_instance.doi).to eq(nil)
      expect(subclass_instance.digital_object_type).to eq('test_subclass')
      expect(subclass_instance.state).to eq('active')
      expect(subclass_instance.created_by).to eq(nil)
      expect(subclass_instance.updated_by).to eq(nil)
      expect(subclass_instance.last_published_by).to eq(nil)
      expect(subclass_instance.created_at).to be_a(DateTime)
      expect(DateTime.now.to_time - subclass_instance.created_at.to_time).to be < 1
      # expecting less than a second of difference
      expect(subclass_instance.updated_at).to be_a(DateTime)
      # expecting less than a second of difference
      expect(DateTime.now.to_time - subclass_instance.updated_at.to_time).to be < 1
      # updated_at time should never be earlier than created_at time
      expect(subclass_instance.updated_at).to be >= subclass_instance.created_at
      expect(subclass_instance.published_at).to eq(nil)
      expect(subclass_instance.first_published_at).to eq(nil)
      expect(subclass_instance.admin_set).to eq(nil)
      expect(subclass_instance.projects).to eq([])
      expect(subclass_instance.descriptive_data).to eq({})
      expect(subclass_instance.publication_data).to eq({})
    end

    it "has the expected resources based on what is defined in the class" do
      expect(subclass_instance.resources.keys.sort).to eq([:test_resource1, :test_resource2])
    end

    context "#new_record?" do
      it "returns true for a newly created instance" do
        expect(subclass_instance.new_record?).to eq(true)
      end
    end

    context "#to_digital_object_data" do
      let (:digital_object_data) { subclass_instance.to_digital_object_data }
      it "returns a Hash with keys for all defined attributes, and all resources under a 'resources' key" do
        expect(digital_object_data).to be_a(Hash)
        expect(
          digital_object_data.keys.sort
        ).to eq(
          subclass_instance.attributes.keys.push('resources').map { |key| key.to_s }.sort
        )
      end

      it "returns the expected custom resource keys, nested under a top 'resources' key" do
        expect(digital_object_data).to be_a(Hash)
        expect(
          digital_object_data['resources'].keys.sort
        ).to eq(
          subclass_instance.resources.keys.map { |key| key.to_s }.sort
        )
      end
    end
  end
end
