class AddRequeueCountToDigitalObjectImports < ActiveRecord::Migration
  def change
    add_column :digital_object_imports, :requeue_count, :integer, default: 0, null: false
  end
end
