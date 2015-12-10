class CreateCsvExports < ActiveRecord::Migration
  def change
    create_table :csv_exports do |t|
      t.text :search_params
      t.references :user, index: true, foreign_key: true
      t.text :path_to_csv_file
      t.text :export_errors
      t.integer :status, null: false, index: true, default: 0

      t.timestamps null: false
    end
  end
end
