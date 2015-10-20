class CreateControlledVocabularies < ActiveRecord::Migration
  def change
    create_table :controlled_vocabularies do |t|
      t.string :string_key
      t.boolean :only_managed_by_admins, default: false, index: true

      t.timestamps
    end
  end
end
