# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples "a lock adapter" do
  before {
    # This shared spec requires the including context to define an adapter in a variable called adapter
    raise 'Must define variable `adapter` via `let(:adapter)`' unless defined?(adapter)
  }

  context "implements expected methods" do
    it "implements #with_lock" do
      expect(adapter).to respond_to(:with_lock)
    end

    it "implements #locked?" do
      expect(adapter).to respond_to(:locked?)
    end
  end
end
