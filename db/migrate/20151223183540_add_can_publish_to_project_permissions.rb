class AddCanPublishToProjectPermissions < ActiveRecord::Migration[4.2]
  def change
    change_table(:project_permissions) do |t|
      t.boolean :can_publish, :null => false, :default => false
    end
  end
end
