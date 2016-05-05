class ControlledVocabulary < ActiveRecord::Base
  before_create :create_corresponding_uri_service_vocabulary, unless: :corresponding_uri_service_vocabulary_exists?
  after_destroy :delete_corresponding_uri_service_vocabulary, unless: :corresponding_uri_service_vocabulary_has_terms?

  before_update :update_uri_service_display_label

  attr_accessor :display_label

  def display_label
    @display_label ||= begin
      new_record? ? '' : UriService.client.find_vocabulary(string_key)[:display_label]
    end
  end

  def update_uri_service_display_label
    UriService.client.update_vocabulary(string_key, @display_label)
  end

  def corresponding_uri_service_vocabulary_exists?
    UriService.client.find_vocabulary(string_key).present?
  end

  def create_corresponding_uri_service_vocabulary
    UriService.client.create_vocabulary(string_key, display_label) unless corresponding_uri_service_vocabulary_exists?
  end

  def corresponding_uri_service_vocabulary_has_terms?
    UriService.client.list_terms(string_key).length > 0
  end

  def delete_corresponding_uri_service_vocabulary
    UriService.client.delete_vocabulary(string_key) unless corresponding_uri_service_vocabulary_has_terms?
  end
end
