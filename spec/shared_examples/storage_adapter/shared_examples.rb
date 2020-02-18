# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples "an abstract storage adapter" do
  before {
    # This shared spec requires the including context to define variables:
    raise 'Must define adapter via let(:adapter)' unless defined?(adapter)
  }
  context "defines expected methods" do
    ### readable methods ###
    it "implements #readable?" do
      expect(adapter).to respond_to(:readable?)
    end

    it "implements #writable?" do
      expect(adapter).to respond_to(:writable?)
    end

    it "implements #handles?" do
      expect(adapter).to respond_to(:handles?)
    end
    it "implements #read" do
      expect(adapter).to respond_to(:read)
    end
    it "implements #read_impl" do
      expect(adapter).to respond_to(:read_impl)
    end
    it "implements #uri_prefix" do
      expect(adapter).to respond_to(:uri_prefix)
    end

    ### writable methods ###
    it "implements #write" do
      expect(adapter).to respond_to(:write)
    end
    it "implements #write_impl" do
      expect(adapter).to respond_to(:write_impl)
    end
    it "implements #with_writable" do
      expect(adapter).to respond_to(:with_writable)
    end
    it "implements #writable_impl" do
      expect(adapter).to respond_to(:writable_impl)
    end
  end
end

RSpec.shared_examples "a readable storage adapter" do
  before {
    # This shared spec requires the including context to define variables:
    raise 'Must define adapter via let(:adapter)' unless defined?(adapter)
    raise 'Must define adapter via let(:expected_adapter_uri_prefix)' unless defined?(expected_adapter_uri_prefix)
    raise 'Must define adapter via let(:sample_location_uri)' unless defined?(sample_location_uri)
    raise 'Must define adapter via let(:content)' unless defined?(content)
  }

  let(:unhandled_location_uri) { 'unhandled:///a/b/c/d/e' }

  it_behaves_like "an abstract storage adapter"

  it "is readable" do
    expect(adapter.readable?).to eq(true)
  end

  it "#handles?" do
    expect(adapter.handles?(sample_location_uri)).to eq(true)
  end

  it "implements #uri_prefix" do
    expect(adapter.uri_prefix).to eq(expected_adapter_uri_prefix)
  end

  context "#exists?" do
    it "returns true for existing path" do
      expect(adapter.exists?(sample_location_uri)).to eq(true)
    end
    it "returns false for non-existent path" do
      expect(adapter.exists?(sample_location_uri + '.nope')).to eq(false)
    end
  end

  context "#read" do
    it "returns the expected content" do
      expect(adapter.read(sample_location_uri)).to eq(content)
    end
    it "rejects unhandled URIs" do
      expect { adapter.read(unhandled_location_uri) }.to raise_error(Hyacinth::Exceptions::UnhandledLocationError)
    end
  end

  context "#with_readable" do
    it "returns the expected content" do
      adapter.with_readable(sample_location_uri) do |blob|
        expect(blob.read).to eq(content)
      end
    end
    it "rejects unhandled URIs" do
      expect { adapter.with_readable(unhandled_location_uri) {} }.to raise_error(Hyacinth::Exceptions::UnhandledLocationError)
    end
  end
end

RSpec.shared_examples "a readable-writable storage adapter" do
  before {
    # This shared spec requires the including context to define variables:
    raise 'Must define adapter via let(:adapter)' unless defined?(adapter)
    raise 'Must define adapter via let(:expected_adapter_uri_prefix)' unless defined?(expected_adapter_uri_prefix)
    raise 'Must define adapter via let(:sample_location_uri)' unless defined?(sample_location_uri)
  }

  let(:unhandled_location_uri) { 'unhandled:///a/b/c/d/e' }
  let(:new_content) { 'This is new content.' }

  it_behaves_like "an abstract storage adapter"
  it_behaves_like "a readable storage adapter"

  it "is readable" do
    expect(adapter.writable?).to eq(true)
  end

  context "#write" do
    it "can write content and then read that written content" do
      adapter.write(sample_location_uri, new_content)
      expect(adapter.read(sample_location_uri)).to eq(new_content)
    end
    it "rejects unhandled URIs" do
      expect { adapter.write(unhandled_location_uri, new_content) }.to raise_error(Hyacinth::Exceptions::UnhandledLocationError)
    end
  end

  context "#with_writable" do
    it "can write to streamable content and then read that written content" do
      adapter.with_writable(sample_location_uri) { |blob| blob.write new_content }
      adapter.with_readable(sample_location_uri) { |blob| expect(blob.read).to eq(new_content) }
    end
    it "rejects unhandled URIs" do
      expect { adapter.with_writable(unhandled_location_uri) {} }.to raise_error(Hyacinth::Exceptions::UnhandledLocationError)
    end
  end

  context "#delete" do
    it "can write content and then delete that content" do
      adapter.write(sample_location_uri, new_content)
      expect(adapter.exists?(sample_location_uri)).to eq(true)
      adapter.delete(sample_location_uri)
      expect(adapter.exists?(sample_location_uri)).to eq(false)
    end
    it "rejects unhandled URIs" do
      expect { adapter.delete(unhandled_location_uri) }.to raise_error(Hyacinth::Exceptions::UnhandledLocationError)
    end
  end
end
