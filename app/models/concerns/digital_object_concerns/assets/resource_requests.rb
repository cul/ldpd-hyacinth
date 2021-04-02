# frozen_string_literal: true

module DigitalObjectConcerns::Assets::ResourceRequests
  extend ActiveSupport::Concern

  def run_resource_requests
    if !has_access_resource?
      ResourceRequests::AccessJob.perform_later_if_eligible(self)
    elsif !has_poster_resource?
      ResourceRequests::PosterJob.perform_later_if_eligible(self)
    elsif self.featured_thumbnail_region.blank?
      ResourceRequests::FeaturedThumbnailRegionJob.perform_later_if_eligible(self)
    end

    # Fulltext extraction is always done from the master resource, so it's not related to the above logic.
    ResourceRequests::FulltextJob.perform_later_if_eligible(self) unless has_fulltext_resource?
  end
end
