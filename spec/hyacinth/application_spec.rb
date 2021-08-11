# frozen_string_literal: true

require 'rails_helper'

describe Hyacinth::Application do
  context ".version" do
    it "returns the expected value" do
      expect(described_class.version).to eq(File.read(Rails.root.join('VERSION')).strip)
    end
  end
end
