class RequireNotNullForDigitalObjectTimestampColumns < ActiveRecord::Migration[6.0]
  def up
    change_column_null :digital_objects, :created_at, false
    change_column_null :digital_objects, :updated_at, false
  end
end
