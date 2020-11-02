class RemoveIsPrimaryFromProjects < ActiveRecord::Migration[6.0]
  def change
    remove_column :projects, :is_primary, :boolean, default: false, null: false
  end
end
