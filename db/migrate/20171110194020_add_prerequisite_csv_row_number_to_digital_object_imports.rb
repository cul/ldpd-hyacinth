class AddPrerequisiteCsvRowNumberToDigitalObjectImports < ActiveRecord::Migration[4.2]
  def change
    change_table(:digital_object_imports) do |t|
      t.text :prerequisite_csv_row_numbers, null: true
    end

    # Add index to csv_row_number so that we can find the record with
    # csv_row_number equal to another records's prerequisite_csv_row_numbers
    add_index :digital_object_imports, :csv_row_number
  end
end
