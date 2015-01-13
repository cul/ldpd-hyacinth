class DigitalObject::Exhibition < DigitalObject::Base

  VALID_DC_TYPES = ['Exhibition']
  DIGITAL_OBJECT_TYPE_STRING_KEY = 'exhibition'

  def initialize(*args)
    super(*args)
    self.dc_type = VALID_DC_TYPES.first
  end

  # Called during before_save, after all validations have passed
  def get_new_fedora_object
    pid = self.next_pid
    concept = Concept.new(:pid => pid)

    concept.datastreams["DC"].dc_identifier = [pid]
    return concept
  end

end
