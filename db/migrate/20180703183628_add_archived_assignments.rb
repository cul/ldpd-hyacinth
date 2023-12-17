class AddArchivedAssignments < ActiveRecord::Migration[4.2]
  def change
    create_table :archived_assignments do |t|
      t.integer :original_assignment_id, null: false
      t.string :digital_object_pid, null: false
      t.references :project, null: false
      t.integer :task, null: false
      t.text :summary
      t.text :original
      t.text :proposed

      t.index :digital_object_pid
      t.index :task
      t.index :project_id
    end
  end
end
