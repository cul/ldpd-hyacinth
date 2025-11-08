require 'base64'
require 'io/console'

namespace :hyacinth do
  namespace :users do
    # this is ported from the logic in users.js, with a longer default and b64 encoding
    def random_password(len = 24)
      chars = '01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
      result = ''
      (0...len).each { result << chars[rand(0...chars.length)] }
      Base64.strict_encode64(result)
    end

    desc "reset all user account credentials"
    task reset_all_creds: :environment do
      User.find_each do |user|
        user.update!(password: random_password)
      end
    end

    desc "reset a specific user credential to an input value"
    task reset_user_creds: :environment do
      user_id = ENV['id']&.to_i
      unless user_id
        puts "call this task with id=INTEGERID"
        abort
      end
      user = User.find(user_id)
      puts "Enter new password:"
      upw = STDIN.noecho(&:gets)
      upw.strip!
      user.update!(password: upw)
      puts "User<#{user_id}> '#{user.email}' assigned new #{upw.bytesize}-byte password"
    end

    desc "Create service account"
    task create_service_account: :environment do
      required_params = ['uid', 'email', 'first_name', 'last_name', 'api_key']
      missing_required_params = required_params - ENV.keys
      if missing_required_params.present?
        abort("Missing required parameters: #{missing_required_params.join(', ')}")
      end
      user_params = ENV.slice(*required_params)
      puts "Creating user with params: #{user_params}"
      User.create!(user_params.merge({account_type: :service}))

      user = User.create!(
          uid: 'abc123',
          email: 'abc123@columbia.edu',
          first_name: 'ABC',
          last_name: '123',
          is_admin: true,
          account_type: 'service'
        )
        user.reload
          puts user.inspect
    end

    desc "Create admin user"
    task create_admin_user: :environment do
      required_params = ['uid', 'email', 'first_name', 'last_name']
      missing_required_params = required_params - ENV.keys
      if missing_required_params.present?
        abort("Missing required parameters: #{missing_required_params.join(', ')}")
      end
      user_params = ENV.slice(*required_params)
      puts "Creating user with params: #{user_params}"
      User.create!(user_params.merge({account_type: :standard}))
    end
  end
end
