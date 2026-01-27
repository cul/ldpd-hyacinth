module DigitalObject::Assets::FeaturedRegion
  extend ActiveSupport::Concern

  def featured_region=(region)
    region = region.first if region.is_a?(Array)
    @fedora_object.clear_relationship(:region_featured)
    @fedora_object.add_relationship(:region_featured, region, true) if region.present?
  end

  def featured_region
    rels = @fedora_object&.relationships(:region_featured)
    current_value = rels.first.object if rels.present?
    current_value
  end

  def region_selection_event=(event_data)
    event_data = event_data.first if event_data.is_a?(Array)
    @fedora_object.clear_relationship(:region_selection_event)
    if event_data.present?
      event_data['updatedAt'] ||= Time.now.utc.iso8601
      @fedora_object.add_relationship(:region_selection_event, JSON.generate(event_data), true)
    end
  end

  def region_selection_event
    rels = @fedora_object&.relationships(:region_selection_event)
    current_value = rels.first.value if rels.present?
    JSON.load(current_value) || { 'updatedBy' => I18n.t('email.automatic_process'), 'updatedAt' => updated_at.iso8601 }
  end
end
