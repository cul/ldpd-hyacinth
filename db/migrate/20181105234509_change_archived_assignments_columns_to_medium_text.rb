class ChangeArchivedAssignmentsColumnsToMediumText < ActiveRecord::Migration
  def change
    change_column :archived_assignments, :original, :text, limit: 16.megabytes - 1
    change_column :archived_assignments, :proposed, :text, limit: 16.megabytes - 1
  end
end
