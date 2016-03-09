class AddRequireControlledVocabularyManagerPermissionToControlledVocabularies < ActiveRecord::Migration
  def change
    change_table(:controlled_vocabularies) do |t|
      t.remove :only_managed_by_admins
      t.boolean :require_controlled_vocabulary_manager_permission, default: false, null: false, index: true
    end
  end
end