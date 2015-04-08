class CreateEnabledPublishTargets < ActiveRecord::Migration
  def change
    create_table :enabled_publish_targets do |t|
      t.references :project, null: false, index: true
      t.references :publish_target, null: false, index: true
      t.timestamps
    end

  end
end
