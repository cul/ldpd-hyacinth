class CreatePublishTargets < ActiveRecord::Migration[5.2]
  def change
    create_table :publish_targets do |t|
      t.references :project, foreign_key: true
      t.string :string_key
      t.string :display_label
      t.text :publish_url
      t.string :api_key

      t.timestamps
    end
  end
end
