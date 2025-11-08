class RemovePasswordFieldFromUsers < ActiveRecord::Migration[7.0]
  def change
    remove_column :users, :encrypted_password, :string
    # remove_column :users, :reset_password_token, :string
    # remove_column :users, :reset_password_sent_at, :datetime
  end
end
