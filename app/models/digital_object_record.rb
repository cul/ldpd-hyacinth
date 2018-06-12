class DigitalObjectRecord < ActiveRecord::Base
  belongs_to :created_by, class_name: 'User'
  belongs_to :updated_by, class_name: 'User'

  def data_file_path
    Hyacinth::Utils::PathUtils.data_file_path_for_uuid(self.uuid)
  end
end
