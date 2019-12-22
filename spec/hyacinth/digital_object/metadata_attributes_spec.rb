# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Hyacinth::DigitalObject::MetadataAttributes do
  let(:valid_value) { 'GOOD' }

  let(:invalid_value) { 'BAD' }

  let(:klass) do
    Class.new do
      include Hyacinth::DigitalObject::MetadataAttributes
      metadata_attribute :string_field, Hyacinth::DigitalObject::TypeDef::String.new.private_writer
      metadata_attribute :string_field_with_default_value, Hyacinth::DigitalObject::TypeDef::String.new.default(-> { 'default value' }).private_writer
      metadata_attribute :string_field_with_public_writer, Hyacinth::DigitalObject::TypeDef::String.new
      metadata_attribute :string_field_with_validation, Hyacinth::DigitalObject::TypeDef::String.new.validation(proc { |v| v.eql?('GOOD') })
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
    it "adds a public getter method and setter method with #new" do
      expect(instance).to respond_to(:string_field)
      expect(instance).to respond_to(:'string_field_with_public_writer=')
      instance.string_field_with_public_writer = 'new value'
      expect(instance.string_field_with_public_writer).to eq('new value')
    end

    it "can set a default value for the created getter method with #new.default()" do
      expect(instance).to respond_to(:string_field_with_default_value)
      expect(instance.string_field_with_default_value).to eq('default value')
    end

    it "creates a private setter method with #new.private_writer" do
      expect(instance).not_to respond_to(:string_field_with_default_value=)
      expect(instance.private_methods).to include(:string_field_with_default_value=)
    end

    it "validates good value with validation procs" do
      expect(instance).to respond_to(:'string_field_with_validation=')
      instance.string_field_with_validation = valid_value
      expect(instance.string_field_with_validation).to eq(valid_value)
      expect(instance.metadata_attributes[:string_field_with_validation].valid?(valid_value)).to be true
    end

    it "validates bad value with validation procs" do
      expect(instance.metadata_attributes[:string_field_with_validation].valid?(invalid_value)).to be false
    end
  end
end
