class AddAssignmentBlobs < ActiveRecord::Migration[4.2]
  def change
    change_table(:assignments) do |t|
      t.text :original
      t.text :proposed
    end
  end
end
