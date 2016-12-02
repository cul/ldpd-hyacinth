class DropPublishTargets < ActiveRecord::Migration
  def change
    drop_table :publish_targets
  end
end
