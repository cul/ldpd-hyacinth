class DigitalObjectRecord < ApplicationRecord
  belongs_to :created_by, class_name: 'User', optional: true
  belongs_to :updated_by, class_name: 'User', optional: true

  after_initialize :assign_uuid_and_digital_object_data_location_uri!, if: :new_record?

  # def data_file_path
  #   self.uuid.present? ? Hyacinth::Utils::PathUtils.data_file_path_for_uuid(self.uuid) : nil
  # end

  private

  def assign_uuid_and_digital_object_data_location_uri!
    self.uuid = SecureRandom.uuid
    self.digital_object_data_location_uri = Hyacinth::Utils::UriUtils.file_path_to_location_uri(
      Hyacinth::Utils::PathUtils.data_file_path_for_uuid(self.uuid)
    )
  end
end
