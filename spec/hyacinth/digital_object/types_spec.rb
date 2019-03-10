require 'rails_helper'

RSpec.describe Hyacinth::DigitalObject::Types do
  let(:item_type_key) { 'item' }
  let(:item_type_class) { DigitalObject::Item }
  let(:asset_type_key) { 'asset' }
  let(:asset_type_class) { DigitalObject::Asset }
  let(:types) { described_class.new }
  let(:types_instance_with_registered_types) do
    described_class.new.tap do |types_instance|
      types_instance.register(item_type_key, item_type_class)
      types_instance.register(asset_type_key, asset_type_class)
    end
  end

  context '.new / initialize' do
    it 'create a new instance with no registered types when no args are given' do
      expect(described_class.new.keys).to be_empty
    end

    it 'create a new instance with initially registered types when a hash argument is given' do
      expect(described_class.new(
        item_type_key => item_type_class,
        asset_type_key => asset_type_class
      ).keys).to eq([item_type_key, asset_type_key])
    end
  end

  context '#register' do
    it 'registers the given types and makes them available for later recall via #keys' do
      types.register(item_type_key, item_type_class)
      types.register(asset_type_key, asset_type_class)
      expect(types.keys.sort).to eq([item_type_key, asset_type_key].sort)
    end

    it 'raises an error if the given type key has already been registered' do
      types.register(item_type_key, item_type_class)
      expect { types.register(item_type_key, item_type_class) }.to raise_error(Hyacinth::Exceptions::DuplicateTypeError)
    end
  end

  context '#unregister' do
    it 'unregisters the given type' do
      types.register(item_type_key, item_type_class)
      types.register(asset_type_key, asset_type_class)
      expect(types.keys.sort).to eq([item_type_key, asset_type_key].sort)
      types.unregister(item_type_key)
      expect(types.keys.sort).to eq([asset_type_key].sort)
    end
  end

  context '#refresh_caches!' do
    it 'updates internal cache variables to be in sync with @keys_to_classes variable' do
      internal_keys_to_classes_var = types.instance_variable_get('@keys_to_classes')
      internal_keys_to_classes_var[item_type_key] = item_type_class
      expect(types.instance_variable_get('@classes_to_keys')).to be_empty
      expect(types.instance_variable_get('@keys')).to be_empty
      types.refresh_caches!
      expect(types.instance_variable_get('@classes_to_keys')).to eq(internal_keys_to_classes_var.invert)
      expect(types.instance_variable_get('@keys')).to eq(internal_keys_to_classes_var.keys)
    end
  end

  context '#clear!' do
    it 'removes all existing types' do
      expect(types_instance_with_registered_types.keys).not_to be_empty
      types_instance_with_registered_types.clear!
      expect(types_instance_with_registered_types.keys).to be_empty
    end
  end

  context '#keys' do
    it 'returns a list of added type keys' do
      expect(types_instance_with_registered_types.keys.sort).to eq([item_type_key, asset_type_key].sort)
    end
  end

  context '#key_to_class' do
    it 'returns the class associated with the given key' do
      expect(types_instance_with_registered_types.key_to_class(item_type_key)).to eq(item_type_class)
    end

    it 'returns nil if the given key has not been added' do
      expect(types_instance_with_registered_types.key_to_class('invalid')).to eq(nil)
    end
  end

  context '#class_to_key' do
    it 'returns the key associated with the given class' do
      expect(types_instance_with_registered_types.class_to_key(item_type_class)).to eq(item_type_key)
    end

    it 'returns nil if no key is associated with the given class' do
      expect(types_instance_with_registered_types.class_to_key(String)).to eq(nil)
    end
  end

  context '#class_to_key' do
    it 'returns the key associated with the given class' do
      expect(types_instance_with_registered_types.class_to_key(item_type_class)).to eq(item_type_key)
    end

    it 'returns nil if no key is associated with the given class' do
      expect(types_instance_with_registered_types.class_to_key(String)).to eq(nil)
    end
  end
end
