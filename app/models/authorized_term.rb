class AuthorizedTerm < ActiveRecord::Base
  belongs_to :controlled_vocabulary

  before_create :create_associated_fedora_object!, :set_local_value_uri_if_blank

  validates :value, presence: {allow_blank: false, message: 'An Authorized Term value cannot be blank.'}
  validates :unique_value_and_value_uri_hash, presence: true, uniqueness: {message: 'An Authorized Term with the same Value and Value URI already exists.'}

  def next_pid
    self.controlled_vocabulary.next_pid
  end

  def create_associated_fedora_object!
    pid = self.next_pid
    concept = Concept.new(:pid => pid)

    concept.datastreams["DC"].dc_identifier = [pid]
    concept.datastreams["DC"].dc_type = self.controlled_vocabulary.string_key.camelize # turn "some_key" into "SomeKey" to follow dc_type format convention
    concept.datastreams["DC"].dc_title = concept.datastreams["DC"].dc_type[0] + " term: " + self.value
    concept.label = concept.datastreams["DC"].dc_title[0]
    concept.save

    self.pid = concept.pid
  end

  def set_local_value_uri_if_blank
    if self.value_uri.blank?
      # Our local authority URI is the reposiory url for this object

      # The repository connection could be over http or https, but we don't want URIs to be inconsistent if we switch the connection type later on.
      # Always use "http" for now (like other authorities, including id.loc.gov and schema.org).  If this ever changes, we'll want to do a global update anyway.
      self.value_uri = (ActiveFedora.config.credentials[:url] + '/objects/' + self.pid).gsub(/^https/, 'http')
    end

  end

  def update_unique_value_and_value_uri_hash!
    self.unique_value_and_value_uri_hash = Digest::SHA256.hexdigest((self.value.blank? ? '' : self.value) + (self.value_uri.blank? ? '' : self.value_uri))
  end

  def value=(new_value)
    write_attribute_return_value = write_attribute(:value, new_value)
    update_unique_value_and_value_uri_hash!
    return write_attribute_return_value
  end

  def value_uri=(new_value_uri)
    write_attribute_return_value = write_attribute(:value_uri, new_value_uri)
    update_unique_value_and_value_uri_hash!
    return write_attribute_return_value
  end

end
