class CreateDefaultUserAccounts < ActiveRecord::Migration[5.1]
  def change
    default_user_accounts = [
      {
        email: 'hyacinth-admin@library.columbia.edu',
        password: 'iamtheadmin',
        first_name: 'Admin',
        last_name: 'User',
        is_admin: true
      },
      {
        email: 'hyacinth-test@library.columbia.edu',
        password: 'iamthetest',
        first_name: 'Test',
        last_name: 'User',
        is_admin: false
      }
    ]

    default_user_accounts.each do |account_info|
      # Create admin user
      User.create!(
        :email => account_info[:email],
        :password => account_info[:password],
        :password_confirmation => account_info[:password],
        :first_name => account_info[:first_name],
        :last_name => account_info[:last_name],
        :is_admin => account_info[:is_admin]
      )
    end
  end
end
