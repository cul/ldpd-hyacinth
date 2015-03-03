class CreatePidGenerators < ActiveRecord::Migration
  def change
    create_table :pid_generators do |t|
      t.string :namespace, unique: true
      t.string :template
      t.string :seed
      t.integer :sequence, null: false, default: 0
      t.timestamps
    end

    add_index :pid_generators, :namespace, :unique => true
  end
end
