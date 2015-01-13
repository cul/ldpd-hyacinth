require 'rails_helper'

RSpec.describe "DigitalObjects", :type => :request do
  describe "GET /digital_objects" do
    it "returns a 401 (unauthorized) status when a user is not logged in" do
      get digital_objects_path
      expect(response.status).to be(401)
    end

    it "returns a 200 (success) status when a user IS logged in" do
      request_spec_sign_in_test_user()

      get digital_objects_path
      expect(response.status).to be(200)
    end
  end
end
