class SetUpHyacinthManagedContentJob
  extend Hyacinth::Utils::FedoraUtils::DatastreamMigrations::ClassMethods

  def self.perform(asset_pid, original_dsid, clone_dsid = nil)
    clone_dsid ||= default_clone_dsid(original_dsid)
    if completed?(asset_pid, original_dsid, clone_dsid)
      result = { status: true, message: "previously completed #{self.name}" }
    else
      if original_dsid == clone_dsid
        raise "cannot set #{original_dsid} up from '#{clone_dsid}'; please clone and remove '#{original_dsid}' before running #{self.name}"
      end
      raise "Hyacinth expects to import to content datastream" unless original_dsid == 'content'
      result = copy_fedora_managed_to_hyacinth_managed(fedora_object_pid, clone_dsid)
    end
    raise result[:message] unless result[:status]
    queue_successor(fedora_object_pid, src_dsid, target_dsid)
    result
  end

  def self.queue_successor(fedora_object_pid, src_dsid, target_dsid)
    Resque.enqueue(CleanUpFedoraManagedDatastreamRemovalJob, fedora_object_pid, original_dsid, clone_dsid)
  end

  def self.completed?(asset_pid, original_dsid, clone_dsid = nil)
    return false unless original_dsid == 'content'
    clone_dsid ||= default_clone_dsid(original_dsid)
    hyc_obj = DigitalObject::Base.find(asset_pid)
    fcr_obj = hyc_obj.fedora_object
    original_ds = fcr_obj.datastreams[src_dsid]
    return false unless exists?(original_ds) && original_ds.external?
    clone_ds = fcr_obj.datastreams[clone_dsid]
    if exists?(clone_ds)
      return false unless original_ds.ds_label == clone_ds.ds_label
      return compare_content_descriptors(original_ds, clone_ds)[:status]
    end
    true
  end

  def self.copy_fedora_managed_to_hyacinth_managed(fedora_object_pid, clone_dsid)
    hyc_obj = DigitalObject::Base.find(asset_pid)
    fcr_obj = hyc_obj.fedora_object
    clone_ds = fcr_obj.datastreams[clone_dsid]
    return {
      status: false,
      message: "no #{clone_dsid} datastream for #{fcr_obj.pid}"
    } unless exists?(clone_ds)

    original_file_path = clone_ds.ds_label

    Tempfile.create('managed-content', encoding: 'ascii-8bit') do |ds_content_tempfile|
      # stream the current content into tempfile and close to writes
      stream_ds(repository, clone_ds) do |chunk|
        ds_content_tempfile << chunk
      end
      ds_content_tempfile.close
      hyc_obj.instance_variable_set(:@import_file_original_file_path, original_file_path)
      hyc_obj.instance_variable_set(:@import_file_import_path, ds_content_tempfile.path)
      hyc_obj.instance_variable_set(:@import_file_import_type, DigitalObject::Asset::IMPORT_TYPE_INTERNAL)
      hyc_obj.do_file_import # this will create new content ds
      hyc_obj.save
    end
  end
end
