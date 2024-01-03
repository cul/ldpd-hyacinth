class CreateControlledVocabularies < ActiveRecord::Migration[4.2]
  def change
    create_table :controlled_vocabularies do |t|
      t.string :string_key
      t.boolean :only_managed_by_admins, default: false, index: true

      t.string :pid # Will be deleted in the future
      t.string :display_label # Will be deleted in the future
      t.references :pid_generator, index: true # Will be deleted in the future

      t.timestamps
    end
  end
end
