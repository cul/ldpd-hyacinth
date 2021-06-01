class CloneFedoraManagedDatastreamJob
  extend Hyacinth::Utils::FedoraUtils::DatastreamMigrations::ClassMethods

  def self.perform(fedora_object_pid, original_dsid = DEFAULT_ASSET_DSID, clone_dsid = nil)
    clone_dsid ||= default_clone_dsid(original_dsid)
    if completed?(fedora_object_pid, original_dsid, clone_dsid)
      result = { status: true, message: "previously completed #{self.name}" }
    else
      result = clone_to_dsid(fedora_object_pid, original_dsid, clone_dsid)
    end
    raise result[:message] unless result[:status]
    queue_successor(fedora_object_pid, original_dsid, clone_dsid)
    result
  end

  def self.completed?(fedora_object_pid, original_dsid = DEFAULT_ASSET_DSID, clone_dsid = nil)
    clone_dsid ||= default_clone_dsid(original_dsid)
    obj = repository.find(fedora_object_pid)
    original_ds = obj.datastreams[original_dsid]
    clone_ds = obj.datastreams[clone_dsid]
    return false unless exists?(clone_ds) && (clone_ds.external? || clone_ds.dsSize > 0)
    if exists?(original_ds) && !original_ds.external?
      result = (original_ds.ds_label == clone_ds.ds_label)
      result &= (original_ds.controlGroup == clone_ds.controlGroup)
      result &= compare_content_descriptors(original_ds, clone_ds)[:status]
    else
      # src_ds may have been removed in subsequent step; was prerequisite completed?
      result = BackUpFedoraManagedDatastreamJob.completed?(fedora_object_pid, original_dsid, clone_ds)
    end
    result
  end

  def self.queue_successor(fedora_object_pid, original_dsid, clone_dsid)
    Resque.enqueue(RemoveLegacyDatastreamJob, fedora_object_pid, original_dsid, clone_dsid)
  end

  def self.version_clone_opts(repository, src_ds, src_ds_version, ds_content_tempfile)
    ds_opts = src_ds_version.profile.symbolize_keys
    # some profile attributes have to be renamed for REST API
    ds_opts[:checksum] = ds_opts.delete(:dsChecksum)
    ds_opts[:checksumType] = ds_opts.delete(:dsChecksumType)
    ds_opts[:controlGroup] = ds_opts.delete(:dsControlGroup)
    ds_opts[:formatURI] = ds_opts.delete(:dsFormatURI)
    ds_opts[:mimeType] = ds_opts.delete(:dsMIME)
    ds_opts[:versionable] = ds_opts.delete(:dsVersionable)
    # some profile attributes have to be deleted for REST API
    ds_opts.delete(:dsInfoType)
    ds_opts.delete(:dsLocationType)
    ds_opts.delete(:dsVersionID)
    return ds_opts if src_ds.external?
    # do not include location if content is Managed or Xml, use content
    ds_opts.delete(:dsLocation)

    # ensure that DS size and checksum are being tracked
    stream_ds(repository, src_ds_version) do |chunk|
      ds_content_tempfile << chunk
    end
    ds_content_tempfile.close
    ds_opts[:content] = File.open(ds_content_tempfile.path)
    ds_opts[:dsSize] = ds_opts[:content].size
    ds_opts
  end

  def self.clone_to_dsid(fedora_object_pid, src_dsid, target_dsid, force = false)
    repository = Rubydora.connect(Rails.application.config_for(:fedora))
    obj = repository.find(fedora_object_pid)
    src_ds = obj.datastreams[src_dsid]
    target_ds = obj.datastreams[target_dsid]
    unless exists?(src_ds)
      return {
        status: false,
        msg: "Source datastream #{src_dsid} does not exist"
      }
    end
    if exists?(target_ds) && !force
      return {
        status: false,
        msg: "Target datastream #{target_dsid} already exists and force == false"
      }
    end
    if src_ds.versionable
      versions = src_ds.versions.sort_by { |ds_version| ds_version.lastModifiedDate }
      first_version = versions.shift
      # create a new DS from first version props
      # - open a tempfile
      Tempfile.create('managed-content', encoding: 'ascii-8bit') do |ds_content_tempfile|
        ds_opts = version_clone_opts(repository, src_ds, first_version, ds_content_tempfile)
        ds_opts[:dsid] = target_dsid
        ds_opts[:pid] = fedora_object_pid
        ds_opts[:logMessage] = "clone #{src_dsid} as of #{first_version.dsCreateDate} to #{target_dsid}"
        repository.add_datastream(ds_opts)
      end
      # create new versions from subsequent source version props
      versions.each do |ds_version|
        Tempfile.create('managed-content', encoding: 'ascii-8bit') do |ds_content_tempfile|
          ds_opts = version_clone_opts(repository, src_ds, ds_version, ds_content_tempfile)
          ds_opts[:dsid] = target_dsid
          ds_opts[:pid] = fedora_object_pid
          ds_opts[:logMessage] = "clone #{src_dsid} as of #{ds_version.dsCreateDate} to #{target_dsid}"
          repository.modify_datastream(ds_opts)
        end
      end
    else
      Tempfile.create('managed-content', encoding: 'ascii-8bit') do |ds_content_tempfile|
        ds_opts = version_clone_opts(repository, src_ds, src_ds, ds_content_tempfile)
        ds_opts[:dsid] = target_dsid
        ds_opts[:pid] = fedora_object_pid
        ds_opts[:logMessage] = "clone #{src_dsid} (unversioned) to #{target_dsid}"
        repository.add_datastream(ds_opts)
      end
    end
    {
      status: true,
      msg: "Cloned #{fedora_object_pid}.#{src_dsid} to #{fedora_object_pid}.#{target_dsid}"
    }
  rescue Exception => e
    Rails.logger.error(e)
    {
      status: false,
      msg: "Error cloning #{src_dsid} to #{target_dsid}: #{e.message}"
    }
  end
end
