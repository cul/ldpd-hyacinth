require 'digest'
require 'tempfile'

module Hyacinth::Utils::FedoraUtils::DatastreamMigrations
  DEFAULT_ASSET_DSID = 'content'

  def repository
    @repository ||= Rubydora.connect(Rails.application.config_for(:fedora))
  end

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

  def self.default_migration_target_dsid(src_dsid = nil)
    "legacy#{(src_dsid || DEFAULT_ASSET_DSID).capitalize}"
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

  def self.verify_identical_content(fedora_object_pid, src_dsid, target_dsid)
    obj = repository.find(fedora_object_pid)
    compare_content_descriptors(obj.datastreams[src_dsid], obj.datastreams[target_dsid])
  end

  def self.compare_content_descriptors(src_ds, target_ds)
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
        msg: "common content descriptor for #{src_ds.dsid} and #{target_ds.dsid}: #{src_data}"
      }
    else
      {
        status: false,
        msg: "content descriptor mismatch #{src_dsid} (#{src_data}); #{target_dsid} (#{target_data})"
      }
    end
  end
end
