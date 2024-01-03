class AddProhibitTempTermsToControlledVocabularies < ActiveRecord::Migration[4.2]
  def change
    change_table(:controlled_vocabularies) do |t|
      t.boolean :prohibit_temp_terms, default: false, null: false
    end
  end
end