class CreatePidGenerators < ActiveRecord::Migration[5.2]
  def change
    create_table :pid_generators do |t|
      t.string :namespace
      t.string :template
      t.string :seed
      t.integer :sequence, null: false, default: 0
      t.timestamps
    end

    add_index :pid_generators, :namespace, :unique => true
  end
end
