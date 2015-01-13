require 'rails_helper'

RSpec.describe "XmlDatastreams", :type => :request do

  describe "GET /xml_datastreams" do
    it "works! (now write some real specs)" do

      request_spec_sign_in_test_user()

      get xml_datastreams_path
      expect(response.status).to be(200)
    end
  end
end
