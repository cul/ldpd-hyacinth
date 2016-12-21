module DigitalObject::Publishing
  extend ActiveSupport::Concern

  def publish
    before_publish

    # Save withg retry after Fedora timeouts / unreachable host
    Retriable.retriable DigitalObject::Base::RETRY_OPTIONS do
      @fedora_object.save(update_index: false)
    end
    allowed_publish_target_pids = allowed_publish_targets.map { |pub_target_data| pub_target_data[:pid] }
    inactive_publish_target_pids = allowed_publish_target_pids - publish_target_pids
    active_publish_target_pids = publish_target_pids
    primary_publish_target_pid = project.primary_publish_target_pid

    # - Make sure to unpublish from INACTIVE publish targets before doing publishing to active
    # publish targets, just in case multiple publish targets have the same publish URL.
    # - Also, always publish to primary_publish_target_pid (if active) last so that
    # if that publish mints a DOI and triggers a re-publish for all other targets, those
    # other targets are able to index the already-minted DOI.
    ordered_publish_target_pids = inactive_publish_target_pids + active_publish_target_pids
    if ordered_publish_target_pids.include?(primary_publish_target_pid)
      # Move primary_publish_target_pid to the end of the array so that it's processed last
      ordered_publish_target_pids.delete(primary_publish_target_pid)
      ordered_publish_target_pids << primary_publish_target_pid
    end

    ordered_publish_target_pids.each do |publish_target_pid|
      publish_action = inactive_publish_target_pids.include?(publish_target_pid) ? :unpublish : :publish
      publish_target = DigitalObject::Base.find(publish_target_pid)
      do_ezid_update = publish_target.pid == primary_publish_target_pid
      execute_publish_action_for_target(publish_action, publish_target, do_ezid_update)
    end

    @errors.blank?
  end

  def execute_publish_action_for_target(publish_action, publish_target, do_ezid_update)
    success = false
    begin
      if publish_action == :unpublish
        response = publish_target.unpublish_digital_object(self, do_ezid_update)
      elsif publish_action == :publish
        response = publish_target.publish_digital_object(self, do_ezid_update)
      end
      success = response.code == 200
      @errors.add(:publish_target, "Error encountered while #{publish_action.to_s + 'ing'} to #{publish_target.get_title}") unless success
    rescue RestClient::Unauthorized
      @errors.add(:publish_target, "Not authorized to #{publish_action} to #{publish_target.get_title}. Check credentials.")
    rescue RestClient::NotFound
      @errors.add(:publish_target, "404 Not Found received for Publish Target URL: #{publish_target.publish_target_field('publish_url')}")
    end
    success
  end
end
