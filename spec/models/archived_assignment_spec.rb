require 'rails_helper'

RSpec.describe ArchivedAssignment, :type => :model do
  describe ".from_assignment" do
    let(:assignment) {
      Assignment.new(
        id: 123,
        task: Assignment.tasks.keys.first,
        status: Assignment.statuses.keys.last,
        digital_object_pid: 'abc:123',
        assigner: User.new(first_name: 'Assigner', last_name: 'User'),
        assignee: User.new(first_name: 'Assignee', last_name: 'User'),
        project: Project.new(display_label: 'Sample Project'),
        created_at: DateTime.now,
        updated_at: (DateTime.now + 2.hours),
        note: 'This is a great note.',
        original: 'This is the original content.',
        proposed: 'This is the proposed content.'
      )
    }
    it "sets all of the expected properties and creates a valid ArchivedAssignment" do
      archived_assignment = ArchivedAssignment.from_assignment(assignment)
      expect(archived_assignment).to be_an(ArchivedAssignment)

      expect(archived_assignment.original_assignment_id).to eq(assignment.id)
      expect(archived_assignment.task).to eq(assignment.task)
      expect(archived_assignment.digital_object_pid).to eq(assignment.digital_object_pid)
      expect(archived_assignment.project).to eq(assignment.project)
      expect(archived_assignment.original).to eq(assignment.original)
      expect(archived_assignment.proposed).to eq(assignment.proposed)
      expect(archived_assignment.summary).to eq(
        "Status: #{assignment.status}\n" \
        "Assigner: #{assignment.assigner.full_name}\n" \
        "Assignee: #{assignment.assignee.full_name}\n" \
        "Created: #{assignment.created_at.iso8601}\n" \
        "Completed: #{assignment.updated_at.iso8601}\n" \
        "Note: #{assignment.note.present? ? assignment.note : '[none]'}"
      )
      expect(archived_assignment).to be_valid
    end
  end
end
