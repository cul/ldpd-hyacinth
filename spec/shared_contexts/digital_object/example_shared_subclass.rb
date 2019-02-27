RSpec.shared_context 'sample digital_object_subclass and digital_object_subclass_instance' do
  # Create a subclass instance for testing because the base class is designed to be abstract and cannot be instantiated.
  let(:digital_object_subclass) do
    Class.new(DigitalObject::Base) do
      metadata_attribute :custom_field, Hyacinth::DigitalObject::TypeDef::String.new.default(-> { 'custom default value' })
      resource_attribute :test_resource1
      resource_attribute :test_resource2
    end
  end

  let(:digital_object_subclass_instance) { digital_object_subclass.new }
end
