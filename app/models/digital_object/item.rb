class DigitalObject::Item < DigitalObject::Base
  VALID_DC_TYPES = ['InteractiveResource']
  DIGITAL_OBJECT_TYPE_STRING_KEY = 'item'

  def initialize
    super
    self.dc_type ||= VALID_DC_TYPES.first
  end

  # Called during save, after all validations have passed
  def create_fedora_object
    ContentAggregator.new(pid: next_pid)
  end
end
