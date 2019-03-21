module DigitalObjectConcerns
  module CopyBehavior
    extend ActiveSupport::Concern

    # Copies metadata attributes from the given digital_object to this digital object.
    # @param digital_object [DigitalObject::Base subclass] The digital object to copy from.
    # @param metadata_attributes_to_copy [Array]  Names of the metadata attribute fields to copy.
    def deep_copy_metadata_attributes_from(digital_object, metadata_attribute_names)
      if (fields_not_found = metadata_attribute_names - self.metadata_attributes.keys).present?
        raise ArgumentError, "metadata_attributes not found: #{fields_not_found.join(", ")}"
      end

      metadata_attribute_names.each do |metadata_attribute_name|
        copy_src_value = digital_object.send(metadata_attribute_name)
        is_frozen = copy_src_value.frozen?
        copied_value = Marshal.load(Marshal.dump(copy_src_value))
        copied_value.freeze if is_frozen
        self.send("#{metadata_attribute_name}=", copied_value)
      end
    end

    def deep_copy_instance_variables_from(digital_object, opts = {})
      digital_object.instance_variables.each do |instance_variable_name|
        copy_src_value = digital_object.instance_variable_get(instance_variable_name)
        is_frozen = copy_src_value.frozen?
        copied_value = Marshal.load(Marshal.dump(copy_src_value))
        copied_value.freeze if is_frozen
        self.instance_variable_set(instance_variable_name, copied_value)
      end
    end

    def deep_copy
      copy_instance = self.class.new
      copy_instance.deep_copy_instance_variables_from(self)
      copy_instance
    end
  end
end
