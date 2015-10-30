class Hyacinth::Utils::HashUtils

  def self.find_nested_hash_values(obj, key)
    values = []
    
    if obj.respond_to?(:key?) && obj.key?(key)
      values << obj[key]
    elsif obj.respond_to?(:each)
      obj.each do |element|
        values += find_nested_hash_values(element,key)
      end
    end
    
    return values
  end
  
  # Finds any nested hash that contains the specified key
  def self.find_nested_hashes_that_contain_key(obj, key)
    values = []
    
    if obj.respond_to?(:key?) && obj.key?(key)
      values << obj
    elsif obj.respond_to?(:each)
      obj.each do |element|
        values += self.find_nested_hashes_that_contain_key(element,key)
      end
    end
    
    return values
  end

end
