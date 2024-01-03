class CreateProjectPermissions < ActiveRecord::Migration[4.2]
  def change
    create_table :project_permissions do |t|
      t.references :project, index: true
      t.references :user, index: true
      t.boolean :can_create, :null => false, :default => false
      t.boolean :can_read, :null => false, :default => false
      t.boolean :can_update, :null => false, :default => false
      t.boolean :can_delete, :null => false, :default => false
      t.boolean :is_project_admin, :null => false, :default => false

      t.timestamps
    end

  end
end
