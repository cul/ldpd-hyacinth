# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples "a storage adapter" do
  before {
    # This shared spec requires the including context to define an adapter in a variable called adapter
    raise 'Must define variable `adapter` via `let(:adapter)`' unless defined?(adapter)
  }
  context "implements expected methods" do
    it "implements #handles?" do
      expect(adapter).to respond_to(:handles?)
    end
    it "implements #read" do
      expect(adapter).to respond_to(:read)
    end
    it "implements #read_impl" do
      expect(adapter).to respond_to(:read_impl)
    end
    it "implements #write" do
      expect(adapter).to respond_to(:write)
    end
    it "implements #write_impl" do
      expect(adapter).to respond_to(:write_impl)
    end
    it "implements #uri_prefix" do
      expect(adapter).to respond_to(:write_impl)
    end
  end
end
