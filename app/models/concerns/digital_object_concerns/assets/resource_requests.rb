# frozen_string_literal: true

module DigitalObjectConcerns::Assets::ResourceRequests
  extend ActiveSupport::Concern

  def run_resource_requests
    ResourceRequests::AccessJob.perform_later_if_eligible(self)
    ResourceRequests::PosterJob.perform_later_if_eligible(self)
    ResourceRequests::FeaturedThumbnailRegionJob.perform_later_if_eligible(self)
    ResourceRequests::IiifRegistrationJob.perform_later_if_eligible(self)
    ResourceRequests::FulltextJob.perform_later_if_eligible(self)
  end

  def request_iiif_deregistration
    ResourceRequests::IiifDeregistrationJob.perform_later_if_eligible(self)
  end
end
