# frozen_string_literal: true

require 'rails_helper'

describe Hyacinth::Adapters do
  let(:adapter_namespace) { Hyacinth::Adapters::DigitalObjectSearchAdapter }
  let(:adapter_config_digital_object_search_solr) do
    {
      type: 'Solr',
      url: 'http://localhost:8983/hyacinth_development'
    }
  end

  let(:adapter_config_without_type) do
    {
      some_other: 'config-option'
    }
  end

  let(:adapter_config_with_unresolvable_type) do
    {
      type: 'Class::Does::Not::Exist'
    }
  end

  context ".create_from_config" do
    it "creates a new instance of an adapter from a configuration hash" do
      expect(described_class.create_from_config(adapter_namespace, adapter_config_digital_object_search_solr)).to be_a(Hyacinth::Adapters::DigitalObjectSearchAdapter::Solr)
    end

    it "raises an error if the configuration hash does not have a type" do
      expect { described_class.create_from_config(adapter_namespace, adapter_config_without_type) }.to raise_error(Hyacinth::Exceptions::AdapterNotFoundError)
    end

    context "raises an error if the Adapter class could not be found" do
      let(:invalid_adapter_namespace) { 'Wow::So::Invalid' }

      it "because of an invalid namespace" do
        expect { described_class.create_from_config(invalid_adapter_namespace, adapter_config_with_unresolvable_type) }.to raise_error(Hyacinth::Exceptions::AdapterNotFoundError)
      end

      it "because of an unresolvable type value" do
        expect { described_class.create_from_config(adapter_namespace, adapter_config_with_unresolvable_type) }.to raise_error(Hyacinth::Exceptions::AdapterNotFoundError)
      end
    end
  end
end
