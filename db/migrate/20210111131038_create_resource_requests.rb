class CreateResourceRequests < ActiveRecord::Migration[6.0]
  def change
    create_table :resource_requests do |t|
      t.string  :digital_object_uid, null: false, index: true
      t.integer :job_type, null: false, index: true
      t.integer :status, null: false, default: 0, index: true
      t.text :src_file_location, null: false
      t.text :options
      t.text :processing_errors
    end
  end
end
