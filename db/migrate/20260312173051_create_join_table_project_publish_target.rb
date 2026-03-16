class CreateJoinTableProjectPublishTarget < ActiveRecord::Migration[7.0]
  def change
    create_join_table :projects, :publish_targets do |t|
      t.index [:project_id, :publish_target_id], unique: true, name: 'unique_project_id_and_publish_target_id'
      t.index [:publish_target_id, :project_id], name: 'index_publish_target_id_and_project_id'
    end
  end
end