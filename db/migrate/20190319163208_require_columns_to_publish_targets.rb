class RequireColumnsToPublishTargets < ActiveRecord::Migration[6.0]
  def change
    change_column_null :publish_targets, :string_key, false
    change_column_null :publish_targets, :display_label, false
    change_column_null :publish_targets, :publish_url, false
    change_column_null :publish_targets, :api_key, false
  end
end
