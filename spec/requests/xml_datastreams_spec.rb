require 'rails_helper'

RSpec.describe "XmlDatastreams", :type => :request do

  describe "GET /xml_datastreams" do
    it "returns a successful status" do

      request_test_sign_in_admin_user

      get xml_datastreams_path
      expect(response.status).to be(200)
    end
  end
end
