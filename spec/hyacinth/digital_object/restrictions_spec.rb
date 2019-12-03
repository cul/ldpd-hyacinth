# frozen_string_literal: true

require 'rails_helper'

describe Hyacinth::DigitalObject::Restrictions do
  let(:restriction_name) { :example }
  let(:klass) do
    Class.new do
      include Hyacinth::DigitalObject::Restrictions
      restriction_attribute :example, Hyacinth::DigitalObject::TypeDef::Boolean.new.default(proc { false })
    end
  end

  let(:instance) do
    klass.new
  end

  context "module inclusion" do
    it "adds the expected methods to the class" do
      expect(klass.restriction_attributes).to be_a(Hash)
    end

    it "adds the expected methods to an instance" do
      expect(instance.restriction_attributes).to be_a(Hash)
    end
  end

  context ".restrictions" do
    it "adds a public getter method" do
      expect(instance).to respond_to(:restrictions)
    end

    it "accesses individual restrictions indifferently by key" do
      expect(instance.restrictions[:example]).to be false
      expect(instance.restrictions['example']).to be instance.restrictions[:example]
    end
  end
end
