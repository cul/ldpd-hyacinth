class CreateXmlDatastreams < ActiveRecord::Migration[4.2]
  def change
    create_table :xml_datastreams do |t|
      t.string :string_key, unique: true, limit: 64 # Fedora Datastreams have a max length of 64 characters
      t.string :display_label, unique: true
      t.text :xml_translation

      t.timestamps
    end
  end
end
