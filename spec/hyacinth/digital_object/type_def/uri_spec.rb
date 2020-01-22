# frozen_string_literal: true

require 'rails_helper'

describe Hyacinth::DigitalObject::TypeDef::Uri do
  let(:type_def) { described_class.new }
  it "accepts a file URI" do
    expect(type_def.valid?("file:/path/to.file")).to be true
  end
  it "accepts an info URI" do
    expect(type_def.valid?("info:fedora/pid:value")).to be true
  end
  it "accepts http[s] URIs" do
    expect(type_def.valid?("http://example.org")).to be true
    expect(type_def.valid?("https://example.org/index.html")).to be true
  end
  describe Hyacinth::DigitalObject::TypeDef::Uri::Http do
    it "accepts http[s] URIs" do
      expect(type_def.valid?("http://example.org")).to be true
      expect(type_def.valid?("https://example.org/index.html")).to be true
    end
    it "rejects file and info URIs" do
      expect(type_def.valid?("file:/path/to.file")).to be false
    end
    it "rejects hostless URIs" do
      expect(type_def.valid?("info:fedora/pid:value")).to be false
    end
  end
end
