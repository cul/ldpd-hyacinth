class CreateS3RestorationRequest < ActiveRecord::Migration[7.0]
  def change
    create_table :s3_restoration_requests do |t|
      t.string :s3_uri
      t.bigint :object_size

      t.timestamps
    end
  end
end
