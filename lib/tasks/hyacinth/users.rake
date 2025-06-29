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
  end
end
