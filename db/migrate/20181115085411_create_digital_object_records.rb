# frozen_string_literal: true

class CreateDigitalObjectRecords < ActiveRecord::Migration[5.2]
  def change
    create_table :digital_object_records do |t|
      t.string :uid, null: false
      t.string :metadata_location_uri, length: 1000
      t.string :optimistic_lock_token, length: 36 # it's a UUIDv4
    end

    add_index :digital_object_records, :uid, unique: true
  end
end
