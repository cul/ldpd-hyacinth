class AddStringKeyToPublishTargets < ActiveRecord::Migration[4.2]
  def change
    change_table(:publish_targets) do |t|
      t.string :string_key, null: true
    end

    add_index :publish_targets, :string_key, :unique => true
  end
end
