class DigitalObject::FileSystem < DigitalObject::Base
  VALID_DC_TYPES = ['FileSystem']
  DIGITAL_OBJECT_TYPE_STRING_KEY = 'file_system'

  def initialize
    super
    self.dc_type ||= VALID_DC_TYPES.first
  end

  # Called during save, after all validations have passed
  def create_fedora_object
    pid = self.next_pid
    Collection.new(:pid => pid)
  end

  def publish_structures
    # TODO: deal with FileSystem structuring in Hyacinth 
  end
end
