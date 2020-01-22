class CreateProjects < ActiveRecord::Migration[6.0]
  def change
    create_table :projects do |t|
      t.string :string_key
      t.string :display_label

      t.timestamps
    end
  end
end
