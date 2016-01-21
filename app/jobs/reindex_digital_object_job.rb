class ReindexDigitalObjectJob
  @queue = Hyacinth::Queue::DIGITAL_OBJECT_REINDEX

  def self.perform(digital_object_pid)
    # Pass false param to update_index() method so that we don't do a Solr commit for each update (because that would be inefficient).
    DigitalObject::Base.find(digital_object_pid).update_index(false)
  end
end
