# frozen_string_literal: true

class AddUidToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :uid, :string
    change_column_null :users, :uid, false
    add_index :users, :uid, unique: true
  end
end
