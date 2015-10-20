# This module authenticates users for request specs.
module ValidUserRequestHelper
  def request_spec_sign_in_admin_user
      @user_for_request ||= FactoryGirl.create(:admin_user)
      post_via_redirect user_session_path, 'user[email]' => @user_for_request.email, 'user[password]' => @user_for_request.password
  end
end

RSpec.configure do |config|
  config.include ValidUserRequestHelper, type: :request
end