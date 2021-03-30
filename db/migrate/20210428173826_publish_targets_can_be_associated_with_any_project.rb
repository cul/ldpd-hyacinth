class PublishTargetsCanBeAssociatedWithAnyProject < ActiveRecord::Migration[6.0]
  def change
    remove_index :publish_targets, [:project_id, :target_type]
    remove_column :publish_targets, :target_type, :string
    remove_column :publish_targets, :project_id, :string

    add_column :publish_targets, :string_key, :string
    add_index :publish_targets, :string_key, unique: true

    create_table :projects_publish_targets do |t|
      t.references :project, null: false
      t.references :publish_target, null: false
    end

    # Need to declare foreign keys manually, otherwise Rails runs into an issue
    add_foreign_key :projects_publish_targets, :projects, column: 'project_id'
    add_foreign_key :projects_publish_targets, :publish_targets, column: 'publish_target_id'
    add_index :projects_publish_targets, [:project_id, :publish_target_id], unique: true, name: 'unique_project_and_publish_target'
  end
end
