class AddSortNameToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :sort_name, :string
    add_index :users, :sort_name

    reversible do |dir|
      dir.up do
        # Re-save all users so that sort_name field is set for each.
        User.find_each { |user| user.save }
      end

      # No need for a dir.down part of this migration because deletion
      # of the sort_name column would undo the dir.up change.
    end
  end
end
