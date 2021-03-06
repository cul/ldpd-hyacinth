class CreatePermissions < ActiveRecord::Migration[6.0]
  def change
    create_table :permissions do |t|
      t.belongs_to :group, index: true

      t.string :action, null: false
      t.string :subject
      t.string :subject_id

      t.timestamps
    end
  end
end
