class ChangeControlledVocabulariesRemoveUnusedFields < ActiveRecord::Migration[4.2]
  def change
    change_table :controlled_vocabularies do |t|
      t.remove :pid
      t.remove :display_label
      t.remove_references :pid_generator
    end
  end
end
