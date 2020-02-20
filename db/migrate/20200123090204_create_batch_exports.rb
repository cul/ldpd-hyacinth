# frozen_string_literal: true

class CreateBatchExports < ActiveRecord::Migration[6.0]
  def change
    create_table :batch_exports do |t|
      t.text :search_params
      t.belongs_to :user, index: true
      t.text :file_location
      t.text :export_errors
      t.integer :status, null: false, index: true, default: 0
      t.integer :duration, null: false, default: 0
      t.integer :number_of_records_processed, null: false, default: 0

      t.timestamps
    end
  end
end
