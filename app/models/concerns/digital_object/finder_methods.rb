module DigitalObject::FinderMethods
  extend ActiveSupport::Concern

  module ClassMethods
    # Find/Save/Validate

    # Returns true if the given pid exists or if all pids in the given array exist
    def exists?(pids)
      pids = Array(pids)
      pids.length == ::DigitalObjectRecord.where(pid: pids).count
    end

    # Finds objects by PID
    def find(pid)
      digital_object_record = ::DigitalObjectRecord.find_by(pid: pid)

      if digital_object_record.nil?
        raise Hyacinth::Exceptions::DigitalObjectNotFoundError, "Couldn't find DigitalObject with pid #{pid}"
      end

      # Retry after Fedora timeouts / unreachable host
      fobj = nil
      Retriable.retriable DigitalObject::Base::RETRY_OPTIONS do
        fobj = ActiveFedora::Base.find(pid)
      end

      digital_object = DigitalObject::Base.get_class_for_fedora_object(fobj).new
      digital_object.init_from_digital_object_record_and_fedora_object(digital_object_record, fobj)
      digital_object
    end

    # Like self.find(), but returns nil when a DigitalObject isn't found instead of raising an error
    def find_by_pid(pid)
      find(pid)
    rescue Hyacinth::Exceptions::DigitalObjectNotFoundError
      return nil
    end

    def find_all_by_identifier(identifier)
      # First attempt a solr lookup.  If records are found in solr, we don't need to do a Fedora lookup.
      search_response = DigitalObject::Base.search('f' => { 'identifiers_sim' => [identifier] }, 'fl' => 'pid', 'per_page' => 99_999)

      pids = []

      if search_response['results'].present?
        search_response['results'].each do |result|
          pids << result['pid']
        end
      else
        # Fall back to Fedora resource index lookup
        pids = Cul::Hydra::RisearchMembers.get_all_pids_for_identifier(identifier)
      end

      pids.map { |obj_pid| find_by_pid(obj_pid) }
    end
  end
end
