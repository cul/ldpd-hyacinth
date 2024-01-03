class AddAssignmentNote < ActiveRecord::Migration[4.2]
  def change
    change_table(:assignments) do |t|
      t.text :note
    end
  end
end
