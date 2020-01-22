# frozen_string_literal: true

class CreateDatabaseEntryLock < ActiveRecord::Migration[6.0]
  def change
    create_table :database_entry_locks do |t|
      t.string :lock_key, null: false
      t.datetime :created_at, null: false
      t.datetime :expires_at, null: false
    end

    add_index :database_entry_locks, :lock_key, unique: true
  end
end
