class RemoveOriginalDatastreamJob
  extend Hyacinth::Utils::FedoraUtils::DatastreamMigrations

  def self.perform(fedora_object_pid, original_dsid = DEFAULT_ASSET_DSID, clone_dsid = nil)
    clone_dsid ||= default_clone_dsid(original_dsid)
  end

  def self.queue_successor(fedora_object_pid, original_dsid, clone_dsid)
    Resque.enqueue(SetUpHyacinthManagedContentJob, fedora_object_pid, original_dsid, clone_dsid)
  end

  def self.completed?(fedora_object_pid, original_dsid = DEFAULT_ASSET_DSID, clone_dsid = nil)
    clone_dsid ||= default_clone_dsid(original_dsid)
  end
end
