class AddCanManageAllControlledVocabulariesToUsers < ActiveRecord::Migration
  def change
    change_table(:users) do |t|
      t.boolean :can_manage_all_controlled_vocabularies, null: false, default: false
    end
  end
end
