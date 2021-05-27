class CleanUpFedoraManagedDatastreamRemovalJob
  extend Hyacinth::Utils::FedoraUtils::DatastreamMigrations

  def self.perform(fedora_object_pid, original_dsid = DEFAULT_ASSET_DSID, clone_dsid = nil)
    clone_dsid ||= default_clone_dsid(original_dsid)
  end

  def self.queue_successor(fedora_object_pid, src_dsid, target_dsid); end

  def self.completed?(fedora_object_pid, src_dsid = DEFAULT_ASSET_DSID, target_dsid = nil)
    clone_dsid ||= default_clone_dsid(original_dsid)
  end
end
