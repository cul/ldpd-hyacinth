class CreatePublishEntries < ActiveRecord::Migration[6.0]
  def change
    create_table :publish_entries do |t|
      t.references :digital_object, null: false, index: true
      t.references :publish_target, null: false, index: true
      t.references :published_by, null: true
      t.datetime :published_at
      t.text :citation_location, null: true
    end

    # Need to declare foreign keys manually, otherwise Rails runs into an issue
    add_foreign_key :publish_entries, :digital_objects, column: 'digital_object_id'
    add_foreign_key :publish_entries, :publish_targets, column: 'publish_target_id'
    add_foreign_key :publish_entries, :users, column: 'published_by_id'
    add_index :publish_entries, [:digital_object_id, :publish_target_id], unique: true, name: 'unique_digital_object_and_publish_target'
  end
end
