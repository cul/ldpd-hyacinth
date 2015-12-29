
class PublishTarget < ActiveRecord::Base

  has_many :projects, :through => :enabled_publish_targets
  has_many :enabled_publish_targets, :dependent => :destroy
  
  attr_encrypted :api_key, :key => HYACINTH['publish_target_api_key_encryption_key'], mode: :per_attribute_iv_and_salt

  before_create :create_associated_fedora_object!
  after_save :update_fedora_object!
  after_destroy :mark_fedora_object_as_deleted!

  validates :string_key, length: { maximum: 100, message: ' is required (100 characters max).' }, allow_blank: false
  validates :publish_url, length: { maximum: 1000, too_long: "can only have a maximum of %{count} characters." }
  validates :api_key, length: { maximum: 100, too_long: "can only have a maximum of %{count} characters." }

  # Returns the associated Fedora Object
  def fedora_object
    if self.pid.present?
      return @fedora_object ||= ActiveFedora::Base.find(self.pid)
    else
      return nil
    end
  end

  def create_associated_fedora_object!
    pid = PidGenerator.default_pid_generator.next_pid
    concept = Concept.new(:pid => pid)
    @fedora_object = concept
    self.pid = @fedora_object.pid
  end

  def update_fedora_object!
    self.fedora_object.datastreams["DC"].dc_identifier = [pid]
    self.fedora_object.datastreams["DC"].dc_type = 'Publish Target'
    self.fedora_object.datastreams["DC"].dc_title = self.display_label
    self.fedora_object.label = self.display_label
    self.fedora_object.save
  end

  def mark_fedora_object_as_deleted!
    self.fedora_object.state = 'D'
    self.fedora_object.save
  end

  def as_json(options={})
    return {
      pid: self.pid,
      display_label: self.display_label,
      string_key: self.string_key
    }
  end

end
