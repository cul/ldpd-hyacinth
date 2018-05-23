class AddAssignmentBlobs < ActiveRecord::Migration
  def change
    change_table(:assignments) do |t|
      t.text :original
      t.text :proposed
    end
  end
end
