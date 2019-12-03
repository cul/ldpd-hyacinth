class AddIsPrimaryToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :is_primary, :boolean, default: false
  end
end
