class AddTotalRecordsToProcessToBatchExports < ActiveRecord::Migration[6.0]
  def change
    add_column :batch_exports, :total_records_to_process, :integer, default: 0, null: false
  end
end
