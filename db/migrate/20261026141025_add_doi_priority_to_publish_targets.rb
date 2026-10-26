class AddDoiPriorityToPublishTargets < ActiveRecord::Migration[7.0]
  def change
    add_column :publish_targets, :doi_priority, :integer
    add_index :publish_targets, :doi_priority, unique: true
  end
end
