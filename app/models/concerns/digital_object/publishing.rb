module DigitalObject::Publishing
  extend ActiveSupport::Concern

  def publish(preserve = true)
    before_publish

    # Save with retry after Fedora timeouts / unreachable host
    Retriable.retriable DigitalObject::Base::RETRY_OPTIONS do
      fedora_object.save(update_index: false) if preserve
    end
    active_publish_targets = PublishTarget.where(string_key: @publish_target_string_keys).to_a
    inactive_publish_targets = project.publish_targets.to_a - active_publish_targets
    # The DOI should point to the active publish target with the highest priority
    doi_publish_target = active_publish_targets.select(&:doi_priority).min_by(&:doi_priority)

    puts "Active publish targets: #{active_publish_targets}"
    puts "Inactive publish targets #{inactive_publish_targets}"
    puts "DOI publish target #{doi_publish_target}"

    # - Make sure to unpublish from INACTIVE publish targets before doing publishing to active
    # publish targets, just in case multiple publish targets have the same publish URL.
    should_unpublish_from_doi_priority_target = false
    inactive_publish_targets.each do |publish_target|
      response = execute_publish_action_for_target(:unpublish, publish_target)
      puts "Unpublish response #{response}"
      should_unpublish_from_doi_priority_target = true if response && publish_target.doi_priority
    end

    doi_publish_target_response = nil
    active_publish_targets.each do |publish_target|
      response = execute_publish_action_for_target(:publish, publish_target)
      puts "Publish response #{response}"
      doi_publish_target_response = response if publish_target == doi_publish_target
    end

    update_doi_after_publishing(doi_publish_target, doi_publish_target_response, should_unpublish_from_doi_priority_target)

    @errors.blank?
  end

  def update_doi_after_publishing(doi_publish_target, doi_publish_target_response, should_unpublish_from_doi_priority_target)
    if doi_publish_target
      location = doi_publish_target_response&.headers&.dig(:location)
      puts "Location: #{location}"
      update_doi_metadata(location) if location.present?
    elsif should_unpublish_from_doi_priority_target && doi.present?
      change_doi_status_to_unavailable
    end
  rescue Hyacinth::Exceptions::DataciteErrorResponse,
         Hyacinth::Exceptions::DataciteConnectionError,
         Hyacinth::Exceptions::MissingDoi => e
    @errors.add(:datacite, e.message)
  end

  def unpublish_all
    @publish_target_string_keys = []
    publish
  end

  def execute_publish_action_for_target(publish_action, publish_target)
    success = false
    begin
      if publish_action == :unpublish
        response = publish_target.unpublish_digital_object(pid)
      elsif publish_action == :publish
        response = publish_target.publish_digital_object(pid)
      end
      success = response.code == 200
      @errors.add(:publish_target, "Error encountered while #{publish_action}ing to #{publish_target.display_label}") unless success
    rescue Errno::ECONNREFUSED
      @errors.add(:publish_target, "Connection to server refused for Publish Target URL: #{publish_target.publish_url}")
    rescue RestClient::ExceptionWithResponse => e
      @errors.add(
        :publish_target,
        "#{e.response&.code || 'Undefined'} response received for Publish Target URL: #{publish_target.publish_url}\n"\
        "Error message: #{e.message}"
      )
    end
    success ? response : nil
  end

  def publishing_to_primary_publish_target?
    @publish_after_save && publish_target_pids.include?(project.primary_publish_target_pid)
  end
end
