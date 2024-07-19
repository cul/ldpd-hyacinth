module DigitalObject::Publishing
  extend ActiveSupport::Concern

  def publish(preserve = true)
    before_publish

    # Save with retry after Fedora timeouts / unreachable host
    Retriable.retriable DigitalObject::Base::RETRY_OPTIONS do
      fedora_object.save(update_index: false) if preserve
    end
    allowed_publish_target_pids = allowed_publish_targets.map { |pub_target_data| pub_target_data['pid'] }
    inactive_publish_target_pids = allowed_publish_target_pids - publish_target_pids
    active_publish_target_pids = publish_target_pids
    primary_publish_target_pid = project.primary_publish_target_pid

    # - Make sure to unpublish from INACTIVE publish targets before doing publishing to active
    # publish targets, just in case multiple publish targets have the same publish URL.
    ordered_publish_target_pids = inactive_publish_target_pids + active_publish_target_pids

    ordered_publish_target_pids.each do |publish_target_pid|
      publish_action = inactive_publish_target_pids.include?(publish_target_pid) ? :unpublish : :publish
      publish_target = DigitalObject::Base.find(publish_target_pid)
      do_ezid_update = publish_target.pid == primary_publish_target_pid
      execute_publish_action_for_target(publish_action, publish_target, do_ezid_update)
    end

    @errors.blank?
  end

  def unpublish_all
    @publish_target_pids = []
    publish
  end

  def execute_publish_action_for_target(publish_action, publish_target, do_ezid_update)
    return true if publish_target.publish_target_field('publish_url').blank? # Not all publish targets have publish URLs. Skip and return true if that's true for this pub target.
    success = false
    begin
      if publish_action == :unpublish
        response = publish_target.unpublish_digital_object(self, do_ezid_update)
      elsif publish_action == :publish
        response = publish_target.publish_digital_object(self, do_ezid_update)
      end
      success = response.code == 200
      @errors.add(:publish_target, "Error encountered while #{publish_action}ing to #{publish_target.get_title}") unless success
    rescue Errno::ECONNREFUSED
      @errors.add(:publish_target, "Connection to server refused for Publish Target URL: #{publish_target.publish_target_field('publish_url')}")
    rescue RestClient::ExceptionWithResponse => e
      response_code = response_code_for_exception(e)
      @errors.add(:publish_target, "#{response_code} response received for Publish Target URL: #{publish_target.publish_target_field('publish_url')}")
    end
    success
  end

  def publishing_to_primary_publish_target?
    @publish_after_save && publish_target_pids.include?(project.primary_publish_target_pid)
  end

  private
    def response_code_for_exception(e)
      response_code = e.response.code if e.response
      response_code || :nil
    end
end
