class AddProjectUrlToProjects < ActiveRecord::Migration[6.0]
  def change
    add_column :projects, :project_url, :string

    change_column_null :projects, :string_key, false
    add_index :projects, :string_key, unique: true

    change_column_null :projects, :display_label, false
    add_index :projects, :display_label, unique: true
  end
end
