
class PublishTarget < ActiveRecord::Base
  has_many :projects, through: :enabled_publish_targets
  has_many :enabled_publish_targets, dependent: :destroy

  attr_encrypted :api_key, key: HYACINTH['publish_target_api_key_encryption_key'], mode: :per_attribute_iv_and_salt

  before_create :create_associated_fedora_object!
  after_save :update_fedora_object!
  #after_save :create_hyacinth_digital_object_if_not_exist!
  after_destroy :mark_fedora_object_as_deleted!

  validates :string_key, length: { maximum: 100, message: ' is required (100 characters max).' }, allow_blank: false
  validates :publish_url, length: { maximum: 1000, too_long: "can only have a maximum of %{count} characters." }
  validates :api_key, length: { maximum: 100, too_long: "can only have a maximum of %{count} characters." }

  # Returns the associated Fedora Object
  def fedora_object
    if pid.present?
      return @fedora_object ||= ActiveFedora::Base.find(pid)
    else
      return nil
    end
  end

  def create_associated_fedora_object!
    pid = PidGenerator.default_pid_generator.next_pid
    concept = Concept.new(pid: pid)
    @fedora_object = concept
    self.pid = @fedora_object.pid
  end

  def update_fedora_object!
    fedora_object.datastreams["DC"].dc_identifier = [pid]
    fedora_object.datastreams["DC"].dc_type = 'Publish Target'
    fedora_object.datastreams["DC"].dc_title = display_label
    fedora_object.label = display_label
    fedora_object.save(update_index: false)
    
    create_hyacinth_digital_object_if_not_exist!
  end

  def create_hyacinth_digital_object_if_not_exist!

    publish_target = DigitalObject::PublishTarget.new
    publish_target.set_digital_object_data(
      {
        'pid' => fedora_object.pid,
        'project' => { 'string_key' => 'publish_targets' },
        'publish_target_data' => {
          'string_key' => string_key,
          'api_key' => api_key,
          'publish_url' => publish_url
        },
        'dynamic_field_data' => {
          'title' => [
            'title_sort_portion' => display_label
          ]
        }
      },
      false
    )

    publish_target.created_by = User.find(1) # Terrible way to do this, but this is temporary code
    publish_target.updated_by = User.find(1) # Terrible way to do this, but this is temporary code

    publish_target.save

    raise publish_target.errors.inspect if publish_target.errors.present?
  end

  def mark_fedora_object_as_deleted!
    fedora_object.state = 'D'
    fedora_object.save(update_index: false)
  end

  def as_json(_options = {})
    {
      pid: pid,
      display_label: display_label,
      string_key: string_key
    }
  end
end
