class AddFirstPublishedAtToDigitalObjectRecords < ActiveRecord::Migration[4.2]
  def change
    add_column :digital_object_records, :first_published_at, :datetime
  end
end
