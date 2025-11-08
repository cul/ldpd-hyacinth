class AddAccountTypeToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :account_type, :integer, null: false, default: 0
    add_index :users, :account_type

    # Then populate all of the uid fields, based on existing email addresses
    # User.find_each do |user|
    #   unless user.email.end_with?('@columbia.edu')
    #     user.update!(account_type: :service)
    #   end
    # end
  end
end
