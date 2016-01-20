module Hyacinth::Utils::FedoraUtils
  extend Logger::Behavior

  def self.import_fedora_object_as_hyacinth_item(fedora_object_pid, project_string_key, import_type, parent_digital_object_pid = nil)
    valid_import_types = ['item', 'recursive']
    unless valid_import_types.include?(import_type)
      raise 'Invalid import_type.  Must be one of: ' + VALID_IMPORT_TYPES.join(', ')
    end

    unless Project.where(string_key: project_string_key).length == 1
      raise 'Could not find project with string_key: ' + project_string_key
    end

    unless parent_digital_object_pid.blank?
      unless DigitalObject.where(pid: parent_digital_object_pid).length == 1
        raise 'Could not find parent DigitalObject with PID: ' + parent_digital_object_pid
      end
    end

    unless ActiveFedora::Base.exists?(fedora_object_pid)
      raise 'Could not find Fedora object with pid: ' + fedora_object_pid
    end
  end

  def self.immediate_member_of_parent?(child_fedora_object_pid, parent_fedora_object_pid)
    immediate_member_query = 'select $pid from <#ri>
    where
    $pid <http://purl.oclc.org/NET/CUL/memberOf> <info:fedora/' + parent_fedora_object_pid + '>
    and
    $pid <mulgara:is> <info:fedora/' + child_fedora_object_pid + '>'
    ri_opts = {
      type: 'tuples',
      format: 'json',
      limit: '',
      stream: 'on'
    }
    search_response = Cul::Hydra::Fedora.repository.find_by_itql(immediate_member_query, ri_opts)
    search_response = JSON(search_response)
    num_results = search_response['results'].length
    if num_results == 1
      return true
    elsif num_results == 1
      return false
    else
      raise 'Unexpected response for risearch.  Resulted in ' + num_results.to_s + ' search results.'
    end
  end

  def self.get_or_create_namespace_object(namespace_string)
    namespace_pid = namespace_string + ':namespace'

    begin
      namespace_fedora_object = BagAggregator.find(namespace_pid)
    rescue ActiveFedora::ObjectNotFoundError
      # Create top_level_all_content_fedora_object if it wasn't found
      namespace_fedora_object = BagAggregator.new(pid: namespace_pid)
      namespace_fedora_object.label = 'Top level object for the ' + namespace_string + ' namespace'
      namespace_fedora_object.datastreams["DC"].dc_identifier = namespace_string + '_namespace'
      namespace_fedora_object.save(update_index: false)
    end

    namespace_fedora_object
  end
end
