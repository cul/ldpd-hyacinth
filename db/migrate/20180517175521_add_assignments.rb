class AddAssignments < ActiveRecord::Migration
  def change
    create_table :assignments do |t|
      t.string :digital_object_pid, null: false
      t.references :project,  null: false
      t.references :assigner, null: false
      t.references :assignee, null: false
      t.integer :status
      t.integer :task
      t.timestamps

      t.index [:digital_object_pid, :task], unique: true
      t.index :assigner_id
      t.index :assignee_id
      t.index :project_id
    end
  end
end
