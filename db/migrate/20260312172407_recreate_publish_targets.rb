class RecreatePublishTargets < ActiveRecord::Migration[7.0]
  def change
    create_table :publish_targets do |t|
      t.string :string_key, null: false
      t.string :display_label, null: false
      t.string :publish_url, null: false
      t.string :api_key, null: false

      t.timestamps precision: nil
    end

    add_index :publish_targets, :string_key, unique: true
  end
end