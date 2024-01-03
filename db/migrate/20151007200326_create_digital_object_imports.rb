class CreateDigitalObjectImports < ActiveRecord::Migration[4.2]

  def change

    create_table :digital_object_imports do |t|

      t.text :digital_object_data
      t.integer :status, null: false, index: true, default: 0
      t.text :digital_object_errors
      t.belongs_to :import_job, null: false, index: true

      t.timestamps null: false

    end

  end

end
