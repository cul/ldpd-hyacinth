class ProjectPermission < ApplicationRecord
  belongs_to :project
  belongs_to :user

  before_save :do_before_safe_stuff

  validates :user, :project, presence: true

  def do_before_safe_stuff
    self.can_read ||= true # If this project_permission exists, then self.can_read should always be true

    # If a ProjectPermission has is_project_admin set, then set all other permissions to true
    return unless is_project_admin

    self.can_create = true
    self.can_update = true
    self.can_delete = true
    self.can_publish = true
  end
end
