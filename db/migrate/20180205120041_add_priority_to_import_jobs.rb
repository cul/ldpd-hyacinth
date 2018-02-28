class AddPriorityToImportJobs < ActiveRecord::Migration
  def change
    change_table(:import_jobs) do |t|
      t.integer :priority, null: false, index: true, default: 0
    end
  end
end
