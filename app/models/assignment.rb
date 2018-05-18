class Assignment < ActiveRecord::Base
  belongs_to :assigner, class_name: 'User'
  belongs_to :project
  belongs_to :digital_object_record, class_name: 'DigitalObjectRecord'
  belongs_to :assignee, class_name: 'User'
  enum task: { annotate: 0, describe: 1, sequence: 2, transcribe: 3 }
  enum status: { unassigned: 0, assigned: 1, in_progress: 2, ready: 3, in_review: 4, accepted: 5 }
end
