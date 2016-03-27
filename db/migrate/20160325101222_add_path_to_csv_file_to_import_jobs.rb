class AddPathToCsvFileToImportJobs < ActiveRecord::Migration
  def change
    change_table(:import_jobs) do |t|
      t.text :path_to_csv_file
    end
  end
end