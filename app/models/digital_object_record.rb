class DigitalObjectRecord < ApplicationRecord
  belongs_to :created_by, class_name: 'User', optional: true
  belongs_to :updated_by, class_name: 'User', optional: true

  def data_file_path
    self.uuid.present? ? Hyacinth::Utils::PathUtils.data_file_path_for_uuid(self.uuid) : nil
  end
end
