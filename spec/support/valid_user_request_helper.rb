# This module authenticates users for request specs.
module ValidUserRequestHelper
  def request_spec_sign_in_admin_user
      @user ||= FactoryGirl.create(:admin_user)
      post_via_redirect user_session_path, 'user[email]' => @user.email, 'user[password]' => @user.password
  end
end

RSpec.configure do |config|
  config.include ValidUserRequestHelper, type: :request
end