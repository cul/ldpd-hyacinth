class CreateJoinTableDigitalObjectRecordPublishTarget < ActiveRecord::Migration[7.0]
  def change
    create_join_table :digital_object_records, :publish_targets do |t|
      t.index [:digital_object_record_id, :publish_target_id], unique: true, name: 'unique_digital_object_record_id_and_publish_target_id'
      t.index :publish_target_id, name: 'index_dor_publish_targets_on_publish_target_id'
    end
  end
end
