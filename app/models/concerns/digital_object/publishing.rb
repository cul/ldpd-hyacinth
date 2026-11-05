module DigitalObject::Publishing
  extend ActiveSupport::Concern

  def publish(preserve = true)
    # Set first_published_at before setting descMetadata fields so we don't send an empty date.
    # Save it to the db if publishing succeeds.
    first_publish = @first_published_at.blank? && @publish_target_string_keys.present?
    @first_published_at = Time.current if first_publish

    before_publish

    # Save with retry after Fedora timeouts / unreachable host
    Retriable.retriable DigitalObject::Base::RETRY_OPTIONS do
      fedora_object.save(update_index: false) if preserve
    end
    active_publish_targets = PublishTarget.where(string_key: @publish_target_string_keys).to_a
    # Only unpublish from deselected targets that the object may still be published to
    possibly_published_target_ids = @db_record.publications.where.not(status: :unpublished).select(:publish_target_id)
    inactive_publish_targets = PublishTarget.where(id: possibly_published_target_ids).where.not(string_key: @publish_target_string_keys).to_a
    # The DOI should point to the active publish target with the highest priority
    doi_publish_target = active_publish_targets.select(&:doi_priority).min_by(&:doi_priority)

    should_unpublish_from_doi_priority_target = false
    inactive_publish_targets.each do |publish_target|
      response = execute_publish_action_for_target(:unpublish, publish_target)
      should_unpublish_from_doi_priority_target = true if response && publish_target.doi_priority
    end

    doi_publish_target_response = nil
    published_to_any_target = false

    active_publish_targets.each do |publish_target|
      response = execute_publish_action_for_target(:publish, publish_target)
      doi_publish_target_response = response if publish_target == doi_publish_target
      published_to_any_target = true if response
    end

    if first_publish && published_to_any_target
      record_first_published_at
    elsif first_publish
      @first_published_at = nil
    end

    update_doi_after_publishing(doi_publish_target, doi_publish_target_response, should_unpublish_from_doi_priority_target)

    @errors.blank?
  end

  def update_doi_after_publishing(doi_publish_target, doi_publish_target_response, should_unpublish_from_doi_priority_target)
    if doi_publish_target
      location = doi_publish_target_response&.headers&.dig(:location)
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
    publication = @db_record.publications.find_or_initialize_by(publish_target: publish_target)
    publication.update!(status: publish_action == :publish ? :publish_pending : :unpublish_pending)

    success = false
    error_message = nil
    begin
      if publish_action == :unpublish
        response = publish_target.unpublish_digital_object(pid)
      elsif publish_action == :publish
        response = publish_target.publish_digital_object(pid)
      end
      success = response.code == 200
      error_message = "Error encountered while #{publish_action}ing to #{publish_target.display_label}" unless success
    rescue Errno::ECONNREFUSED
      error_message = "Connection to server refused for Publish Target URL: #{publish_target.publish_url}"
    rescue RestClient::ExceptionWithResponse => e
      if publish_action == :unpublish && e.http_code == 404
        # The object is already absent from the publish target
        response = e.response
        success = true
      else
        error_message = "#{e.response&.code || 'Undefined'} response received for Publish Target URL: #{publish_target.publish_url}\n"\
                        "Error message: #{e.message}"
      end
    end

    if success
      publication.update!(status: publish_action == :publish ? :published : :unpublished, error_message: nil)
    else
      @errors.add(:publish_target, error_message)
      publication.update!(error_message: error_message)
    end
    success ? response : nil
  end

  def record_first_published_at
    @db_record.update_column(:first_published_at, @first_published_at)
    # Solr was updated before publishing
    update_index
  end
end
