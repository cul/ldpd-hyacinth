require 'rails_helper'

RSpec.describe "DigitalObjects", :type => :request do
  describe "GET /digital_objects" do
    it "returns a 401 (unauthorized) status when a user is not logged in" do
      get digital_objects_path
      expect(response.status).to be(401)
    end

    it "returns a 200 (success) status when a user IS logged in" do
      request_spec_sign_in_admin_user()

      get digital_objects_path
      expect(response.status).to be(200)
    end
  end
  
  describe "authenticated actions" do
    
    let(:sample_item_digital_object_data) { JSON.parse( fixture('sample_digital_object_data/new_item.json').read ) }
    
    before :example do
      request_spec_sign_in_admin_user()
    end
    
    describe "POST /digital_objects" do
      it "returns an error message if the digital_object param is not supplied" do
        request_spec_sign_in_admin_user()
        post(digital_objects_path, {})
        expect(response.status).to be(200)
        response_json = JSON.parse(response.body)
        expect(response_json).to eq({
          'success' => false,
          'errors' => ['Missing param digital_object']
        })
      end
      
      it "returns an error message if an invalid digital_object_type param is supplied" do
        request_spec_sign_in_admin_user()
        
        sample_item_digital_object_data['digital_object_type']['string_key'] = 'invalid_type'
        
        post(digital_objects_path, {
          digital_object: sample_item_digital_object_data
        })
        
        expect(response.status).to be(200)
        response_json = JSON.parse(response.body)
        expect(response_json).to eq({
          'success' => false,
          'errors' => ['Invalid digital_object_type string_key: invalid_type']
        })
      end
      
      it "successfully creates an object when the correct set of parameters are supplied" do
        request_spec_sign_in_admin_user()
        post(digital_objects_path, {
          digital_object: sample_item_digital_object_data
        })
        
        expect(response.status).to be(200)
        response_json = JSON.parse(response.body)
        expect(response_json['success']).to eq(true)
        expect(response_json['pid'].length).not_to eq(0)
      end
    end
  end
  
end
