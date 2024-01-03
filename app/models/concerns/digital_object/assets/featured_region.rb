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

  def asset_image_width
    return nil unless @fedora_object
    width_val = @fedora_object.relationships(:image_width).first
    width_val ||= @fedora_object.rels_int.relationships(@fedora_object.datastreams['content'], :image_width).first&.object
    width_val.to_s.to_i
  end

  def asset_image_height
    return nil unless @fedora_object
    width_val = @fedora_object.relationships(:image_length).first
    width_val ||= @fedora_object.rels_int.relationships(@fedora_object.datastreams['content'], :image_length).first&.object
    width_val.to_s.to_i
  end

  # NOTE: Commenting out this method for now because it isn't being used, but it might be again in the near future.
  # def rotated_region(rotate_by)
  #   original_region = self.featured_region
  #   return original_region if original_region.blank?

  #   original_image_width = self.asset_image_width
  #   original_image_height = self.asset_image_height
  #   original_region_left, original_region_top, original_region_width, original_region_height = original_region.split(',').map(&:to_i)
  #   original_region_right = original_region_left + original_region_width
  #   original_region_bottom = original_region_top + original_region_height
  #   rotate_by = rotate_by % 360
  #   left = original_region_left
  #   width = original_region_width
  #   top = original_region_top
  #   height = original_region_height
  #   case rotate_by
  #   when 90
  #     left = original_image_height - original_region_bottom
  #     width = original_region_height
  #     top = original_region_left
  #     height = original_region_width
  #   when 180
  #     left = original_image_width - original_region_right
  #     top = original_image_height - original_region_bottom
  #   when 270
  #     left = original_region_top
  #     width = original_region_height
  #     top = original_image_width - original_region_right
  #     height = original_region_width
  #   end
  #   "#{left},#{top},#{width},#{height}"
  # end
end
