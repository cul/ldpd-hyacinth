class AddBcp47LanguageSubsystem < ActiveRecord::Migration[6.0]
  def change
    create_table :language_subtags do |t|
      t.string  :subtag, null: false
      t.string  :subtag_type, null: false
      t.datetime :added, null: false
      t.timestamps null: false
      t.string  :scope, null: true
      t.datetime :deprecated, null: true
      t.integer :preferred_value_id, null: true
      t.integer :suppress_script_id, null: true
      t.integer :macrolanguage_id, null: true

      t.text    :prefixes
      t.text    :comments
      t.text    :descriptions
    end
    add_index :language_subtags, [:subtag, :subtag_type], unique: true
    add_index :language_subtags, :subtag_type
    add_index :language_subtags, :preferred_value_id

    create_table :language_tags do |t|
      t.string  :tag, null: false
      t.string  :tag_type, null: false, default: 'redundant'
      t.datetime :added, null: false
      t.timestamps null: false
      t.datetime :deprecated, null: true
      t.integer :preferred_value_id, null: true

      t.text    :comments
      t.text    :descriptions
    end
    add_index :language_tags, :tag, unique: true
    add_index :language_tags, :tag_type
    add_index :language_tags, :preferred_value_id

    create_table :language_subtags_tags do |t|
      t.belongs_to :tag, null: false
      t.belongs_to :subtag, null: false

      t.timestamps
    end
    add_index :language_subtags_tags, [:tag_id, :subtag_id], unique: true, name: 'tag_subtag'
  end
end
