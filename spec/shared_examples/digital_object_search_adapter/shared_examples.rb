# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples "a search adapter" do
  before do
    # This shared spec requires the including context to define an adapter in a variable called adapter
    raise 'Must define variable `adapter` via `let(:adapter)`' unless defined?(adapter)
  end
  context "implements expected methods" do
    it "implements #index" do
      expect(adapter).to respond_to(:index)
    end
    it "implements #remove" do
      expect(adapter).to respond_to(:remove)
    end
    it "implements #search" do
      expect(adapter).to respond_to(:search)
    end
    it "implements #identifier_to_uids" do
      expect(adapter).to respond_to(:identifier_to_uids)
    end
    it "implements #clear_index" do
      expect(adapter).to respond_to(:clear_index)
    end
  end
end
