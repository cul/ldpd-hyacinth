class PublishTarget < ApplicationRecord
  belongs_to :project

  validates :string_key, presence: true, uniqueness: true, string_key: true
  validates :display_label, :publish_url, :api_key, presence: true

  # Publishes the given digital object to this publish target's url,
  # optionally pointing the doi to this publish target if
  # point_doi_to_this_publish_target is given a value of true.
  # @param digital_object [DigitalObject::Base subclass] DigitalObject to publish.
  # @param point_doi_to_this_publish_target [boolean] A flag that determines whether
  #        the published digital object's doi should point to a location associated
  #        with this PublishTarget.
  # @return [success, errors] [boolean, Array<String>] success will be true if
  #         the publish was successful, or false otherwise. errors is an array
  #         that will contain error messages if the publish failed.
  def publish(digital_object, point_doi_to_this_publish_target)
  end

  # @return [success, errors] [boolean, Array<String>] success will be true if
  #         the unpublish was successful, or false otherwise. errors is an array
  #         that will contain error messages if the unpublish failed.
  def unpublish(digital_object)
  end

  def as_json(_options = {})
    {
      project: project.string_key,
      string_key: string_key,
      display_label: display_label,
      publish_url: publish_url,
      api_key: api_key
    }
  end
end
