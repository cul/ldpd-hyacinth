class CreatePublishTargets < ActiveRecord::Migration
  def change
    create_table :publish_targets do |t|
      t.string :pid
      t.string :display_label
      t.string :publish_url, limit: 2000
    end

    add_index :publish_targets, :pid, :unique => true
  end
end
