class CreateVocabulariesAndTerms < ActiveRecord::Migration[5.2]
  def change
    create_table :vocabularies do |t|
      t.string  :label, null: false
      t.string  :string_key, null: false
      t.text    :custom_fields
      t.boolean :locked, default: false

      t.timestamps
    end

    add_index :vocabularies, :string_key, unique: true

    create_table :terms do |t|
      t.belongs_to :vocabulary, index: true, null: false

      t.string :pref_label, null: false
      t.text   :alt_labels
      t.string :uri,        null: false
      t.string :uri_hash,   null: false
      t.string :authority
      t.string :term_type,  null: false
      t.text   :custom_fields
      t.string :uid,       null: false

      t.timestamps
    end

    add_index :terms, :uid, unique: true
    add_index :terms, [:uri_hash, :vocabulary_id], unique: true
  end
end
