class AddDurationAndNumberOfRecordsProcessedToCsvExports < ActiveRecord::Migration[4.2]
  def change
    change_table(:csv_exports) do |t|
      t.integer :duration, :null => false, :default => 0
      t.integer :number_of_records_processed, :null => false, :default => 0
    end
  end
end
