class AddProhibitTempTermsToControlledVocabularies < ActiveRecord::Migration
  def change
    change_table(:controlled_vocabularies) do |t|
      t.boolean :prohibit_temp_terms, default: false, null: false, index: true
    end
  end
end