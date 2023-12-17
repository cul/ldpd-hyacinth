class ChangeArchivedAssignmentsColumnsToMediumText < ActiveRecord::Migration[4.2]
  def change
    change_column :archived_assignments, :original, :text, limit: 16.megabytes - 1
    change_column :archived_assignments, :proposed, :text, limit: 16.megabytes - 1
  end
end
