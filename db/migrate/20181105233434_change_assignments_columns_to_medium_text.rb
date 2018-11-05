class ChangeAssignmentsColumnsToMediumText < ActiveRecord::Migration
  def change
  	change_column :assignments, :original, :text, limit: 16.megabytes - 1
  	change_column :assignments, :proposed, :text, limit: 16.megabytes - 1
  end
end
