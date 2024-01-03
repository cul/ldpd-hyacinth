class Assignment < ApplicationRecord
  include Assignments::Enums

  belongs_to :project
  belongs_to :assigner, class_name: 'User'
  belongs_to :assignee, class_name: 'User'

  validates :assignee, presence: true

  # @return a set of valid actions for the given user, based on that user's privileges
  def allowed_status_change_options_for_user(user)
    options = Set.new
    options.merge(allowed_status_change_options_for_assignee(user)) if self.assignee == user
    options
  end

  def allowed_status_change_options_for_assignee(user)
    options = Set.new

    case self.status
    when 'assigned'
      options << 'in_progress'
    when 'in_progress'
      options << 'assigned'
      options << 'ready_for_review'
    end

    options
  end

  def as_json(_options = {})
    {
      id: id,
      task: task,
      status: status,
      digital_object_pid: digital_object_pid,
      project_id: project_id,
      assigner_id: assigner.id,
      assigner_name: assigner.full_name,
      assignee_id: assignee.id,
      assignee_name: assignee.full_name,
      original: original,
      proposed: proposed
    }
  end
end
