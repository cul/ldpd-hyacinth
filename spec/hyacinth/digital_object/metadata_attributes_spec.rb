require 'rails_helper'

RSpec.describe Hyacinth::DigitalObject::MetadataAttributes do
  let(:valid_value) { 'GOOD' }

  let(:invalid_value) { 'BAD' }

  let(:klass) do
    enum_value = valid_value
    Class.new do
      include Hyacinth::DigitalObject::MetadataAttributes
      metadata_attribute :string_field, Hyacinth::DigitalObject::TypeDef::String.new
      metadata_attribute :string_field_with_default_value, Hyacinth::DigitalObject::TypeDef::String.new.default(-> { 'default value' })
      metadata_attribute :string_field_with_public_writer, Hyacinth::DigitalObject::TypeDef::String.new.public_writer
      metadata_attribute :string_field_with_enumeration, Hyacinth::DigitalObject::TypeDef::String.new.public_writer.constrained_to([enum_value])
    end
  end

  let(:instance) do
    klass.new
  end

  context "module inclusion" do
    it "adds the expected methods to the class" do
      expect(klass.metadata_attributes).to be_a(Hash)
    end

    it "adds the expected methods to an instance" do
      expect(instance.metadata_attributes).to be_a(Hash)
    end
  end

  context ".metadata_attribute" do
    it "adds a public getter method and private setter method with #new" do
      expect(instance).to respond_to(:string_field)
    end

    it "can set a default value for the created getter method with #new.default()" do
      expect(instance).to respond_to(:string_field_with_default_value)
      expect(instance.string_field_with_default_value).to eq('default value')
    end

    it "creates a public setter method with #new.public_writer" do
      expect(instance).to respond_to(:'string_field_with_public_writer=')
      instance.string_field_with_public_writer = 'new value'
      expect(instance.string_field_with_public_writer).to eq('new value')
    end

    it "verifies value in enumerated values" do
      expect(instance).to respond_to(:'string_field_with_enumeration=')
      instance.string_field_with_enumeration = valid_value
      expect(instance.string_field_with_enumeration).to eq(valid_value)
    end

    it "raises an error when an enumerated type does not include a value" do
      expect { instance.string_field_with_enumeration = invalid_value}.to raise_error(ArgumentError)
    end
  end
end
