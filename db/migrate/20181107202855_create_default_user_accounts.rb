class CreateDefaultUserAccounts < ActiveRecord::Migration[5.2]
  def change
    # No longer creating a default user account as part of the migrations. This
    # code was moved to a rake task.
    #
    # default_user_accounts = [
    #   {
    #     email: 'hyacinth-admin@library.columbia.edu',
    #     password: 'iamtheadmin',
    #     first_name: 'Admin',
    #     last_name: 'User'
    #   },
    #   {
    #     email: 'hyacinth-test@library.columbia.edu',
    #     password: 'iamthetest',
    #     first_name: 'Test',
    #     last_name: 'User'
    #   }
    # ]
    #
    # default_user_accounts.each do |account_info|
    #   # Create admin user
    #   User.create!(
    #     :email => account_info[:email],
    #     :password => account_info[:password],
    #     :password_confirmation => account_info[:password],
    #     :first_name => account_info[:first_name],
    #     :last_name => account_info[:last_name]
    #   )
    # end
  end
end
