class AddFirstPublishedAtToDigitalObjectRecords < ActiveRecord::Migration
  def change
    add_column :digital_object_records, :first_published_at, :datetime
  end
end
