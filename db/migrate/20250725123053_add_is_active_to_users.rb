class AddIsActiveToUsers < ActiveRecord::Migration[6.1]
  def change
    change_table(:users) do |t|
      t.boolean :is_active, null: false, default: true
    end
  end
end
