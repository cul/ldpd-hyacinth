class Assignment < ActiveRecord::Base
  belongs_to :assigner, class_name: 'User'
  belongs_to :project
  belongs_to :assignee, class_name: 'User'
  enum task: { annotate: 0, describe: 1, sequence: 2, transcribe: 3 }
  enum status: { unassigned: 0, assigned: 1, in_progress: 2, ready: 3, in_review: 4, accepted: 5 }

  validates :assignee_id, presence: true

  # @return a set of valid actions for the given user, based on that user's privileges
  def allowed_status_change_options_for_user(user)
    options = Set.new
    options.merge(allowed_status_change_options_for_assignee(user)) if self.assignee == user
    options.merge(allowed_status_change_options_for_assigner(user)) if self.assigner == user
    options
  end

  def allowed_status_change_options_for_assignee
    options = Set.new

    case self.status
    when 'assigned'
      options << 'in_progress'
    when 'in_progress'
      options << 'assigned'
      options << 'ready'
    when 'ready'
      options << 'in_progress'
    end

    options
  end

  def allowed_status_change_options_for_assigneer
    options = Set.new

    case self.status
    when 'ready'
      options << 'accept'
    end

    options
  end
end
