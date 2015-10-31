class CreateImportJobs < ActiveRecord::Migration

  def change

    create_table :import_jobs do |t|

      t.string :name, null: false
      t.belongs_to :user, null: false, index: true, foreign_key: true

      t.timestamps null: false

    end

  end

end
