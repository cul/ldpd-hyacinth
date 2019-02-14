require 'rails_helper'

RSpec.describe Hyacinth::DigitalObject::MetadataAttributes do
  let(:klass) do
    Class.new do
      include Hyacinth::DigitalObject::MetadataAttributes
      metadata_attribute :string_field, Hyacinth::DigitalObject::TypeDef::String.new
      metadata_attribute :string_field_with_default_value, Hyacinth::DigitalObject::TypeDef::String.new.default(-> { 'default value' })
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
      expect(instance).to respond_to(:string_field)
      expect(instance.string_field).to eq('default value')
    end

    it "creates a public setter method with #new.public_writer" do
      expect(instance).to respond_to(:'string_field_with_public_setter=')
      instance.string_field_with_default_value = 'new value'
      expect(instance.string_field).to eq('new value')
    end
  end




end
