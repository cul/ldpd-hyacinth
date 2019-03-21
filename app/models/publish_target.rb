class PublishTarget < ApplicationRecord
  belongs_to :project

  # Publishes the given digital object to this publish target's url.
  def publish(digital_object, point_doi_to_this_publish_target)
  end

  def unpublish(digital_object)
  end
end
