# frozen_string_literal: true

require 'rails_helper'

describe Hyacinth::DigitalObject::ResourceAttributes do
  let(:resource_name) { 'example' }
  let(:resource) { Hyacinth::DigitalObject::Resource.new }
  let(:klass) do
    Class.new do
      include Hyacinth::DigitalObject::ResourceAttributes
      resource_attribute :example
    end
  end

  let(:instance) do
    inst = klass.new
    inst.resources[resource_name] = resource
    inst
  end

  context "module inclusion" do
    it "adds the expected methods to the class" do
      expect(klass.resource_attributes).to be_a(Hash)
      expect(klass.resource_attribute_names).to be_a(Array)
    end

    it "adds the expected methods to an instance" do
      expect(instance.resource_attributes).to be_a(Hash)
      expect(instance).to respond_to(:example_resource_name)
      expect(instance).to respond_to(:has_example_resource?)
      expect(instance).to respond_to(:example_resource)
    end

    it "adds the expected resource keys to an instance" do
      expect(instance.resource_attributes).to include(:example)
    end
  end

  context '#x_resource_name' do
    it 'returns the expected value for a registered resource' do
      expect(instance.example_resource_name).to eq(resource_name)
    end
  end

  context '#has_x_resource?' do
    it 'returns the expected value when a resource value is present or absent' do
      expect(instance.has_example_resource?).to eq(true)
      instance.resources['example'] = nil
      expect(instance.has_example_resource?).to eq(false)
    end
  end

  context '#x_resource' do
    it 'returns the expected resource, if present' do
      expect(instance.example_resource).to eq(resource)
      instance.resources['example'] = nil
      expect(instance.example_resource).to eq(nil)
    end
  end

  context ".resources" do
    it "adds a public getter method" do
      expect(instance).to respond_to(:resources)
    end

    before do
      instance.resources[:example] = Hyacinth::DigitalObject::Resource.new
    end

    it "accesses individual resources indifferently by key" do
      expect(instance.resources[:example]).to be_a Hyacinth::DigitalObject::Resource
      expect(instance.resources['example']).to be instance.resources[:example]
    end
  end
end
