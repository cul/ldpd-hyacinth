require 'rails_helper'

RSpec.describe "api key authentication", type: :request do
  let(:basic_auth_header_value) { "Basic #{Base64.strict_encode64("#{uid}:#{api_key}")}" }
  let(:headers_including_authorization_header) do
    { 'Authorization' => basic_auth_header_value }
  end

  describe "performing a request to a login-protected resource" do
    context "without sending a uid and api key" do
      it "returns a 401 (unauthorized) status" do
        get digital_objects_path
        expect(response.status).to be(401)
      end
    end

    context "sending an invalid uid" do
      let(:uid) { 'non-existent-user' }
      let(:api_key) { 'does-not-matter-for-this-test' }

      it "returns a 401 (unauthorized)" do
        get digital_objects_path, headers: headers_including_authorization_header
        expect(response.status).to be(401)
      end
    end

    context "sending an valid uid with an invalid api key" do
      let(:user) { FactoryBot.create(:admin_user) }
      let(:uid) { user.uid }
      let(:api_key) { 'invalid-api-key' }

      it "returns a 401 (unauthorized)" do
        get digital_objects_path, headers: headers_including_authorization_header
        expect(response.status).to be(401)
      end
    end

    context "sending an valid uid with a valid api key" do
      let(:user) { FactoryBot.create(:admin_user) }
      let(:uid) { user.uid }
      let(:api_key) { user.api_key }

      it "returns a 200 (success)" do
        get digital_objects_path, headers: headers_including_authorization_header
        expect(response.status).to be(200)
      end
    end

    # it "returns a 200 (success) status when a user IS logged in" do
    #   request_test_sign_in_admin_user

    #   get digital_objects_path
    #   expect(response.status).to be(200)
    # end
  end
end
