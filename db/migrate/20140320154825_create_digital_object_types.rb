class CreateDigitalObjectTypes < ActiveRecord::Migration[4.2]
  def change
    create_table :digital_object_types do |t|
      t.string :string_key
      t.string :display_label
      t.integer :sort_order, index: true

      t.timestamps
    end
  end
end
