class DigitalObject::Group < DigitalObject::Base

  VALID_DC_TYPES = ['Collection']
  DIGITAL_OBJECT_TYPE_STRING_KEY = 'group'

  def initialize(*args)
    super(*args)
    self.dc_type ||= VALID_DC_TYPES.first
  end

  # Called during save, after all validations have passed
  def get_new_fedora_object
    pid = self.next_pid
    bag_aggregator = BagAggregator.new(:pid => pid)

    bag_aggregator.datastreams["DC"].dc_identifier = [pid]
    return bag_aggregator
  end

end
