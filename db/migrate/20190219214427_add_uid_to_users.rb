class AddUidToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :uid, :string
    change_column_null :users, :uid, false
    add_index :users, :uid, unique: true
  end
end
