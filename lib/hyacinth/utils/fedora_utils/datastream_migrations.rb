require 'digest'
require 'tempfile'

module Hyacinth::Utils::FedoraUtils::DatastreamMigrations
  def self.exists?(ds)
    !(ds.nil? || ds.new?)
  end


  def self.content_descriptor(repository, ds)
    content_digest = Digest::SHA256.new
    content_byte_length = 0
    stream_ds(repository, ds) do |chunk|
      content_byte_length += chunk.length
      content_digest.update(chunk)
    end
    src_data = "bytes:#{content_byte_length};SHA256:#{content_digest.hexdigest}"
  end

  def self.entity_size(http_response)
    if content_length = http_response['Content-Length']
      return content_length.to_i
    end
    http_response.body.length
  end

  def self.stream_ds(repository, ds, &block)
    dissem_opts = { pid: ds.digital_object.pid, dsid: ds.dsid }
    dissem_opts[:asOfDateTime] = ds.asOfDateTime if ds.asOfDateTime
    repository.datastream_dissemination(dissem_opts) do |response|
      size = ds.external? ? entity_size(response) : ds.dsSize
      raise "Can't determine content length" unless size
      length = size

      counter = 0
      response.read_body do |chunk|
        last_counter = counter
        counter += chunk.size
        if counter > length
          # At the end of what we need. Write the beginning of what was read.
          offset = (length) - counter - 1
          block.yield chunk[0..offset]
        else
          # In the middle. We need all of this
          block.yield chunk
        end
      end
    end
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
    unless ds_opts[:checksumType]
      ds_opts[:checksumType] = 'SHA-256'
      ds_digest = Digest::SHA256.new
    end
    stream_ds(repository, src_ds_version) do |chunk|
      ds_content_tempfile << chunk
      ds_digest&.update(chunk)
    end
    ds_content_tempfile.close
    if ds_digest
      ds_opts[:checksum] = ds_digest.hexdigest
    end
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
    if exists?(target_ds)
      return {
        status: false,
        msg: "Target datastream #{target_dsid} already exists and force == false"
      } unless force
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
    {
      status: false,
      msg: "Error cloning #{src_dsid} to #{target_dsid}: #{e.message}"
    }
  end

  def self.verify_identical_content(fedora_object_pid, src_dsid, target_dsid)
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
    unless exists?(target_ds)
      return {
        status: false,
        msg: "Target datastream #{target_dsid} does not exist"
      }
    end
    src_data = content_descriptor(repository, src_ds)
    target_data = content_descriptor(repository, target_ds)
    if src_data == target_data
      {
        status: true,
        msg: "common content descriptor for #{src_dsid} and #{target_dsid}: #{src_data}"
      }
    else
      {
        status: false,
        msg: "content descriptor mismatch #{src_dsid} (#{src_data}); #{target_dsid} (#{target_data})"
      }
    end
  end

  def self.copy_fedora_managed_to_hyacinth_managed(fedora_object_pid, src_dsid, target_dsid)
    repository = Rubydora.connect(Rails.application.config_for(:fedora))
    hyc_obj = DigitalObject::Base.find(asset_pid)
    fcr_obj = hyc_obj.fedora_object
    src_ds = fcr_obj.datastreams[src_dsid]
    return {
      status: false,
      message: "no #{src_dsid} datastream for #{fcr_obj.pid}"
    } unless exists?(src_ds)

    original_file_path = src_ds.ds_label

    Tempfile.create('managed-content', encoding: 'ascii-8bit') do |ds_content_tempfile|
      # stream the current content into tempfile and close to writes
      stream_ds(repository, src_ds) do |chunk|
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
