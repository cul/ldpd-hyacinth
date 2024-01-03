class CreatePublishTargets < ActiveRecord::Migration[4.2]
  def change
    create_table :publish_targets do |t|
      t.string :pid
      t.string :display_label
      t.string :publish_url, limit: 2000
      t.string :encrypted_api_key
      t.string :encrypted_api_key_salt
      t.string :encrypted_api_key_iv
    end

    add_index :publish_targets, :pid, :unique => true
  end
end
