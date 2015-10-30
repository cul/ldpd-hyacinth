class ControlledVocabulary < ActiveRecord::Base

  before_create :create_corresponding_uri_service_vocabulary, unless: :corresponding_uri_service_vocabulary_exists?
  after_destroy :delete_corresponding_uri_service_vocabulary, unless: :corresponding_uri_service_vocabulary_has_terms?
  
  before_update :update_uri_service_display_label
  
  attr_accessor :display_label
  
  def display_label
    
    return @display_label if @display_label
    
    if self.new_record?
      @display_label = ''
    else
      @display_label = UriService.client.find_vocabulary(self.string_key)[:display_label]
    end
    
    puts 'return ' + @display_label
    
    return @display_label
    
  end
  
  def display_label=(new_display_label)
    @display_label = new_display_label
  end
  
  def update_uri_service_display_label
    UriService.client.update_vocabulary(self.string_key, @display_label)
  end
  
  def corresponding_uri_service_vocabulary_exists?
    return UriService.client.find_vocabulary(self.string_key).present?
  end

  def create_corresponding_uri_service_vocabulary
    unless self.corresponding_uri_service_vocabulary_exists?
      return UriService.client.create_vocabulary(self.string_key, self.display_label)
    end
  end
  
  def corresponding_uri_service_vocabulary_has_terms?
    puts 'term check: ' + UriService.client.list_terms(self.string_key).length.inspect
    return UriService.client.list_terms(self.string_key).length > 0
  end

  def delete_corresponding_uri_service_vocabulary
    
    puts 'has terms? ' + self.corresponding_uri_service_vocabulary_has_terms?.inspect
    
    unless self.corresponding_uri_service_vocabulary_has_terms?
      puts 'Deleting ' + self.string_key.inspect
      UriService.client.delete_vocabulary(self.string_key)
    end
  end

end
