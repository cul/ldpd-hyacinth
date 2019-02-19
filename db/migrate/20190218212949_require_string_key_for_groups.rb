class RequireStringKeyForGroups < ActiveRecord::Migration[5.2]
  def change
    change_column_null :groups, :string_key, false
    add_index :groups, :string_key, unique: true
  end
end
