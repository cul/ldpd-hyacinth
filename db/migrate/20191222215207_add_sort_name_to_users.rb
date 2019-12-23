class AddSortNameToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :sort_name, :string
    add_index :users, :sort_name

    # Re-save all users so that sort_name field is set for each.
    User.find_each { |user| user.save }
  end
end
