class AddCsvRowNumberToDigitalObjectImports < ActiveRecord::Migration
  def change
    change_table(:digital_object_imports) do |t|
      t.integer :csv_row_number, null: true
    end
  end
end
