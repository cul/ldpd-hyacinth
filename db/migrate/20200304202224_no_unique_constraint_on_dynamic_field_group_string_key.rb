class NoUniqueConstraintOnDynamicFieldGroupStringKey < ActiveRecord::Migration[6.0]
  def change
    remove_index :dynamic_field_groups, :string_key
    add_index :dynamic_field_groups, :string_key
  end
end
