class AddIsPrimaryToProjects < ActiveRecord::Migration[6.0]
  def change
    add_column :projects, :is_primary, :boolean, default: false, null: false
  end
end
