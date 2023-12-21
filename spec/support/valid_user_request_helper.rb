# This module authenticates users for request specs.
module ValidUserRequestHelper
  def request_spec_sign_in_admin_user
      @user_for_request ||= FactoryBot.create(:admin_user)
      post user_session_path, params: { 'user[email]' => @user_for_request.email, 'user[password]' => @user_for_request.password }
      follow_redirect!
  end
end

RSpec.configure do |config|
  config.include ValidUserRequestHelper, type: :request
end
