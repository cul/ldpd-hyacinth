class ChangeDefaultForDoiPriority < ActiveRecord::Migration[6.0]
  def change
    change_column_default :publish_targets, :doi_priority, 100
  end
end
