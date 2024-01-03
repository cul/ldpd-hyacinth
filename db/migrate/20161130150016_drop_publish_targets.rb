class DropPublishTargets < ActiveRecord::Migration[4.2]
  def change
    drop_table :publish_targets
  end
end
