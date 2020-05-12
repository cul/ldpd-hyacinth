class AddSetupErrorsToBatchImports < ActiveRecord::Migration[6.0]
  def change
    add_column :batch_imports, :setup_errors, :text
  end
end
