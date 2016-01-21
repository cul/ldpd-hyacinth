class ReindexDigitalObjectJob
  @queue = Hyacinth::Queue::DIGITAL_OBJECT_REINDEX

  def self.perform(digital_object_pid)
    DigitalObject::Base.find(digital_object_pid).update_index(false)
  end
end
