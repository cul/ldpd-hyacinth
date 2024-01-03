class AddRequeueCountToDigitalObjectImports < ActiveRecord::Migration[4.2]
  def change
    add_column :digital_object_imports, :requeue_count, :integer, default: 0, null: false
  end
end
