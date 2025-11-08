class AddUidToUsers < ActiveRecord::Migration[7.0]
  def change
    # First add uid column to users table
    add_column :users, :uid, :string
    add_index :users, :uid, unique: true
  end
end
