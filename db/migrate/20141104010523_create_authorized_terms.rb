class CreateAuthorizedTerms < ActiveRecord::Migration
  def change
    
    # This entire table will be deleted in the future
    
    create_table :authorized_terms do |t|
      t.string :pid
      t.text :value, null: false
      t.text :code
      t.text :value_uri
      t.string :unique_value_and_value_uri_hash, limit: 64, index: true, unique: true
      t.text :authority
      t.text :authority_uri
      t.references :controlled_vocabulary, index: true

      t.timestamps
    end
  end
end
