# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Hyacinth::Storage::AbstractStorage do
  let(:storage_config) do
    {
      adapters: [
        {
          uri_protocol: 'managed-disk',
          type: 'ManagedDisk',
          default_path: Rails.root.join('tmp', 'test', 'abstract_storage')
        }
      ]
    }
  end
  let(:storage) { described_class.new(storage_config) }

  context "#storage_adapter_for_location" do
    let(:bad_location) { 'badlocation:///a/b/c' }

    it "raises an exception when no adapter can be found for the given location" do
      expect { storage.storage_adapter_for_location(bad_location) }.to raise_exception(Hyacinth::Exceptions::AdapterNotFoundError)
    end
  end
end
