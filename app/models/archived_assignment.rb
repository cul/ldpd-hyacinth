class ArchivedAssignment < ApplicationRecord
  include Assignments::Enums

  belongs_to :project
  validates :original_assignment_id, :task, :digital_object_pid, :project, :summary, presence: true

  def self.from_assignment(assignment)
    ArchivedAssignment.new(
      original_assignment_id: assignment.id,
      digital_object_pid: assignment.digital_object_pid,
      task: assignment.task,
      project: assignment.project,
      original: assignment.original,
      proposed: assignment.proposed,
      summary:
        "Status: #{assignment.status}\n" \
        "Assigner: #{assignment.assigner.full_name}\n" \
        "Assignee: #{assignment.assignee.full_name}\n" \
        "Created: #{assignment.created_at.iso8601}\n" \
        "Completed: #{assignment.updated_at.iso8601}\n" \
        "Note: #{assignment.note.present? ? assignment.note : '[none]'}"
    )
  end
end
