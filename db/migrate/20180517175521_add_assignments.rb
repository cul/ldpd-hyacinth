class AddAssignments < ActiveRecord::Migration
  def change
    create_table :assignments do |t|
      t.string :digital_object_record_id, limit: 4, null: false
      t.string :project_id, limit: 4, null: false
      t.integer  :assigner_id, limit: 4, null: false
      t.integer  :assignee_id, limit: 4, null: false
      t.integer :status
      t.integer :task
      t.index [:digital_object_record_id, :task], unique: true
      t.index :assigner_id
      t.index :assignee_id
      t.index :project_id
    end
  end
end
