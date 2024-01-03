class AddRequireControlledVocabularyManagerPermissionToControlledVocabularies < ActiveRecord::Migration[4.2]
  def change
    change_table(:controlled_vocabularies) do |t|
      t.remove :only_managed_by_admins
      t.boolean :require_controlled_vocabulary_manager_permission, default: false, null: false, index: { name: "idx_controlled_vocabularies_require_manager_permission"}
    end
  end
end