class DigitalObject::PublishTarget < DigitalObject::Base
  VALID_DC_TYPES = ['Publish Target']
  DIGITAL_OBJECT_TYPE_STRING_KEY = 'publish_target'

  def initialize
    super
    self.dc_type ||= VALID_DC_TYPES.first
  end

  # Called during save, after all validations have passed
  def create_fedora_object
    Concept.new(pid: next_pid)
  end
end
