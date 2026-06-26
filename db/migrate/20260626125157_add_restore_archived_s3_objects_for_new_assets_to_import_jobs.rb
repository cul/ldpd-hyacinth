class AddRestoreArchivedS3ObjectsForNewAssetsToImportJobs < ActiveRecord::Migration[7.0]
  def change
    add_column :import_jobs, :restore_archived_s3_objects_for_new_assets, :boolean, default: false, null: false
  end
end
