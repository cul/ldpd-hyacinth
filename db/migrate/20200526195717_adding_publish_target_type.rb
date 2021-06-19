class AddingPublishTargetType < ActiveRecord::Migration[6.0]
  def change
    add_column :publish_targets, :target_type, :string

    remove_column :publish_targets, :display_label, :string
    remove_column :publish_targets, :string_key, :string

    add_index :publish_targets, [:project_id, :target_type], unique: true
  end
end
