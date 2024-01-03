class AddPerformDerivativeProcessingToDigitalObjectRecords < ActiveRecord::Migration[4.2]
  def change
    change_table(:digital_object_records) do |t|
      t.boolean :perform_derivative_processing, null: false, default: false
    end

    # Add index to csv_row_number so that we can find the record with
    # csv_row_number equal to another records's prerequisite_csv_row_numbers
    add_index :digital_object_records, :perform_derivative_processing
  end
end
