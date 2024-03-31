class AddPerformDerivativeProcessingToDigitalObjectRecords < ActiveRecord::Migration[4.2]
  def change
    change_table(:digital_object_records) do |t|
      t.boolean :perform_derivative_processing, null: false, default: false
    end

    add_index :digital_object_records, :perform_derivative_processing
  end
end
