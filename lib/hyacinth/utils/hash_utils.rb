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

end
