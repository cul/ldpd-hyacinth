require 'rails_helper'

RSpec.describe Hyacinth::Adapters::AdapterManagerBehavior do
  let(:sample_module) do
    Module.new do
      include Hyacinth::Adapters::AdapterManagerBehavior
    end
  end

  let(:adapter_class) do
    Class.new do
      def initialize(adapter_config)
      end
    end
  end

  it "adds the expected methods to the module it's included in" do
    expect(sample_module).to respond_to(:register)
    expect(sample_module).to respond_to(:find)
    expect(sample_module).to respond_to(:create)
    expect(sample_module).to respond_to(:registered_adapters)
  end

  context "registration, finding, and creating" do
    let(:adapter_type) { :sample }
    let(:adapter_config) do
      {
        type: adapter_type,
        config_option_1: 'abc',
        config_option_2: 'def'
      }
    end
    let(:expected_registered_adapters) do
      { adapter_type => adapter_class }
    end
    it "can register, then find, then create an instance for a registered adapter" do
      sample_module.register(adapter_type, adapter_class)
      expect(sample_module.find(adapter_type)).to eq(adapter_class)
      expect(sample_module.create(adapter_config)).to be_a(adapter_class)
      expect(sample_module.registered_adapters).to eq(expected_registered_adapters)
    end

    it "raises an error if the adapter_config's type has not been registered" do
      expect { sample_module.create(adapter_config) }.to raise_error(Hyacinth::Exceptions::AdapterNotFoundError)
    end
  end
end
