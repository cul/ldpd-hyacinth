class DigitalObject::Item < DigitalObject::Base

  VALID_DC_TYPES = ['InteractiveResource']
  DIGITAL_OBJECT_TYPE_STRING_KEY = 'item'

  def initialize(*args)
    super(*args)
    self.dc_type ||= VALID_DC_TYPES.first
  end

  # Called during save, after all validations have passed
  def get_new_fedora_object
    pid = self.next_pid
    content_aggregator = ContentAggregator.new(:pid => pid)

    content_aggregator.datastreams["DC"].dc_identifier = [pid]
    return content_aggregator
  end

end
