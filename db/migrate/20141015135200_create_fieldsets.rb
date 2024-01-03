class CreateFieldsets < ActiveRecord::Migration[4.2]
  def change
    create_table :fieldsets do |t|
      t.string :display_label
      t.references :project, index: true

      t.timestamps
    end
  end
end
