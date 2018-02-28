class DigitalObject::FileSystem < DigitalObject::Base
  VALID_DC_TYPES = ['FileSystem']
  DIGITAL_OBJECT_TYPE_STRING_KEY = 'file_system'

  def initialize
    super
    self.dc_type ||= VALID_DC_TYPES.first
  end

  # Called during save, after all validations have passed
  def create_fedora_object
    Collection.new(pid: next_pid)
  end

  def save_xml_datastreams
    # FileSystem publishing shouldn't modify Fedora object for now
  end

  def save_structure_datastream
    # FileSystem publishing shouldn't modify Fedora object for now
  end
end
