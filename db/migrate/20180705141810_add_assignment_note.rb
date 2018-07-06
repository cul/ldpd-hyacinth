class AddAssignmentNote < ActiveRecord::Migration
  def change
    change_table(:assignments) do |t|
      t.text :note
    end
  end
end
