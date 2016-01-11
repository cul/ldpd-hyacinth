class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :pid

      t.references :pid_generator, index: true
      t.string :display_label
      t.string :string_key
      t.text :full_path_to_custom_asset_directory

      t.timestamps
    end

    add_index :projects, :pid, unique: true
    add_index :projects, :display_label, unique: true
    add_index :projects, :string_key, unique: true

  end
end
