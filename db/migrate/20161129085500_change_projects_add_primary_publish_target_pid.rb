class ChangeProjectsAddPrimaryPublishTargetPid < ActiveRecord::Migration[4.2]
  def change
    change_table :projects do |t|
      t.string :primary_publish_target_pid, null: true
    end
  end
end
