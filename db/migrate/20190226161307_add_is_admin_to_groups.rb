class AddIsAdminToGroups < ActiveRecord::Migration[6.0]
  def change
    add_column :groups, :is_admin, :boolean, default: false
  end
end
