require 'digest'

class BackUpFedoraManagedDatastreamJob
  extend Hyacinth::Utils::FedoraUtils::DatastreamMigrations::ClassMethods

  def self.perform(fedora_object_pid, original_dsid = DEFAULT_ASSET_DSID, _clone_dsid = nil)
    if completed?(fedora_object_pid, original_dsid, _clone_dsid)
      result = { status: true, message: "previously completed #{self.name}" }
    else
      result = backup_dsid(fedora_object_pid, original_dsid, _clone_dsid)
    end
    raise result[:message] unless result[:status]
    queue_successor(fedora_object_pid, original_dsid, _clone_dsid)
    result
  end

  def self.backup_dsid(fedora_object_pid, original_dsid)
    backup_dir_path = backup_dir_for(fedora_object_pid)
    FileUtils.mkdir_p(backup_dir_path)
    ds = repository.datastream(pid: fedora_object_pid, dsid: original_dsid)
    write_backup_profile(backup_dir_path, ds)
    check_profile = backup_profile(fedora_object_pid, original_dsid)
    error_keys = ds.profile.keys.select { |key| ds.profile[key] != check_profile[key] }
    unless error_keys.empty?
      return { status: false, message: "profile backup unsuccessful: #{error_keys.inspect}" }
    end
    streamed_content_descriptor = write_backup_content(backup_dir_path, ds)
    check_content_descriptor = backup_content_descriptor(fedora_object_pid, original_dsid)
    unless streamed_content_descriptor == check_content_descriptor
      return { status: false, message: "content backup unsuccessful: #{streamed_content_descriptor} #{check_content_descriptor}" }
    end
    {
      status: true,
      msg: "Backed up #{fedora_object_pid}.#{src_dsid} to #{backup_dir_path}"
    }
  rescue Exception => e
    Rails.logger.error(e)
    {
      status: false,
      msg: "Error cloning #{src_dsid} to #{target_dsid}: #{e.message}"
    }
  end


  def self.queue_successor(fedora_object_pid, original_dsid, clone_dsid)
    Resque.enqueue(CloneFedoraManagedDatastreamJob, fedora_object_pid, original_dsid, clone_dsid)
  end

  def self.completed?(fedora_object_pid, original_dsid = DEFAULT_ASSET_DSID, _clone_dsid = nil)
    return false unless backup_profile(fedora_object_pid, original_dsid) == current_profile(fedora_object_pid, original_dsid)
    backup_content_descriptor(fedora_object_pid, original_dsid) == content_descriptor(repository, repository.datastream(pid: fedora_object_pid, dsid: original_dsid))
  end

  def self.backup_dir_for(fedora_object_pid)
    dir_name = fedora_object_pid.clone
    dir_name.gsub!('/', '.')
    dir_name.gsub!(':', '_')
    result = File.join(Rails.root, 'log', 'migration-backups', dir_name)
  end

  def self.current_profile(fedora_object_pid, original_dsid = nil)
    dsid = original_dsid || DEFAULT_ASSET_DSID
    repository.datastream_profile(fedora_object_pid, dsid, nil, nil)
  end

  def self.write_backup_profile(backup_dir_path, ds)
    open(File.join(backup_dir_path, "#{ds.dsid}.json")) do |blob|
      blob.write(JSON.pretty_generate(ds.profile))
    end
  end

  def self.backup_profile(fedora_object_pid, original_dsid = nil)
    dsid = original_dsid || DEFAULT_ASSET_DSID
    JSON.load(File.read(File.join(backup_dir_path, "#{dsid}.json")))
  end

  def self.write_backup_content(backup_dir_path, ds)
    content_digest = Digest::SHA256.new
    content_byte_length = 0
    open(File.join(backup_dir_path, "#{ds.dsid}.bin")) do |blob|
      stream_ds(repository, ds) do |chunk|
        blob << chunk
        content_digest.update(chunk)
        content_byte_length += chunk.bytesize
      end
    end
    "bytes:#{content_byte_length};SHA256:#{content_digest.hexdigest}"
  end

  def self.backup_content_descriptor(fedora_object_pid, original_dsid = nil)
    dsid = original_dsid || DEFAULT_ASSET_DSID
    descriptor = "bytes:"
    content_digest = Digest::SHA256.new
    backup_dir_path = backup_dir_for(fedora_object_pid)
    open(File.join(backup_dir_path, "#{dsid}.bin")) do |blob|
      descriptor << blob.size.to_s
      blob.each(nil, 1024**2) { |chunk| content_digest.update(chunk) }
    end
    descriptor << ";SHA256:" << content_digest.hexdigest
  end
end
