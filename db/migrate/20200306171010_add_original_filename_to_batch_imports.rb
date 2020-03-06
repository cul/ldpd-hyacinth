class AddOriginalFilenameToBatchImports < ActiveRecord::Migration[6.0]
  def change
    add_column :batch_imports, :original_filename, :string
  end
end
