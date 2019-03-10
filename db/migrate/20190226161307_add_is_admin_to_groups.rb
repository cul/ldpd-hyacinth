class AddIsAdminToGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :groups, :is_admin, :boolean, default: false
  end
end
