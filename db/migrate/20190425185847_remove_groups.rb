class RemoveGroups < ActiveRecord::Migration[5.2]
  def change
    drop_table :groups
    drop_table :groups_users

    rename_column :permissions, :group_id, :user_id
  end
end
