# frozen_string_literal: true

class AddUidToUsers < ActiveRecord::Migration[5.2]
  def change
    change_table(:users) do |t|
      t.string :uid
    end

    add_index :users, :uid, unique: true
  end
end
