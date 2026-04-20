class AddNotNullAndIndexToXmlDatastreams < ActiveRecord::Migration[7.0]
  def change
    change_column_null :xml_datastreams, :string_key, false
    change_column_null :xml_datastreams, :display_label, false
    change_column_null :xml_datastreams, :xml_translation, false

    add_index :xml_datastreams, :string_key, unique: true
  end
end
