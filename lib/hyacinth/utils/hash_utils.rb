class Hyacinth::Utils::HashUtils
  def self.find_nested_hash_values(obj, key)
    values = []

    if obj.respond_to?(:key?) && obj.key?(key)
      values << obj[key]
    elsif obj.respond_to?(:each)
      obj.each do |element|
        values += find_nested_hash_values(element, key)
      end
    end

    values
  end

  # Finds any nested hash that contains the specified key
  def self.find_nested_hashes_that_contain_key(obj, key)
    values = []

    if obj.respond_to?(:key?) && obj.key?(key)
      values << obj
    elsif obj.respond_to?(:each)
      obj.each do |element|
        values += find_nested_hashes_that_contain_key(element, key)
      end
    end

    values
  end

  def self.recursively_remove_blank_fields_from_hash!(hsh)
    return if hsh.frozen? # We can't modify a frozen hash (e.g. uri-based controlled vocabulary field), so we won't.

    # Step 1: Recursively handle values on lower levels
    hsh.each do |_key, value|
      if value.is_a?(Array)
        # Recurse through non-empty elements
        value.each do |element|
          recursively_remove_blank_fields_from_hash!(element)
        end

        # Delete blank array element values on this array level (including empty object ({}) values)
        value.delete_if(&:blank?)
      elsif value.is_a?(Hash)
        # This code will run when we're dealing with something like a controlled
        # term field, which is a hash that contains a hash as a value.
        recursively_remove_blank_fields_from_hash!(value)
      end
    end

    # Step 2: Delete blank values on this object level
    hsh.delete_if { |_key, value| value.blank? }

    hsh
  end

  def self.recursively_remove_blank_fields_from_hash(hsh)
    hsh_copy = hsh.dup
    recursively_remove_blank_fields_from_hash!(hsh_copy)
  end

end
