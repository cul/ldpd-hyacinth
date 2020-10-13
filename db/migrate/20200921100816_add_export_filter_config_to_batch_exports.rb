class AddExportFilterConfigToBatchExports < ActiveRecord::Migration[6.0]
  def change
    add_column :batch_exports, :export_filter_config, :text, null: true
  end
end
