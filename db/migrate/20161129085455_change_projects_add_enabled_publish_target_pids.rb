class ChangeProjectsAddEnabledPublishTargetPids < ActiveRecord::Migration
  def change
    change_table :projects do |t|
      t.text :enabled_publish_target_pids # This will be a serialized Rails array field
    end
  end
end
