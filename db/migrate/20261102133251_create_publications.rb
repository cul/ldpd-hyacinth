class CreatePublications < ActiveRecord::Migration[7.0]
  def change
    create_table :publications do |t|
      t.references :digital_object_record, null: false, index: false
      t.references :publish_target, null: false
      t.string :status, null: false
      t.text :error_message

      t.timestamps precision: nil
    end

    add_index :publications, [:digital_object_record_id, :publish_target_id], unique: true, name: 'unique_publications_record_and_target'
  end
end
