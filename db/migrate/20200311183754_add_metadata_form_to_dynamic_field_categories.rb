class AddMetadataFormToDynamicFieldCategories < ActiveRecord::Migration[6.0]
  def change
    add_column :dynamic_field_categories, :metadata_form, :integer, default: 0, null: false
  end
end
