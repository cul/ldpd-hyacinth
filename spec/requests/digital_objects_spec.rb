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
    let(:sample_asset_digital_object_data) { JSON.parse( fixture('sample_digital_object_data/new_asset.json').read ) }
    
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
          'errors' => ['Missing param digital_object_data_json']
        })
      end
      
      it "returns an error message if an invalid digital_object_type param is supplied" do
        request_spec_sign_in_admin_user()
        
        sample_item_digital_object_data['digital_object_type']['string_key'] = 'invalid_type'
        
        post(digital_objects_path, {
          digital_object_data_json: JSON.generate(sample_item_digital_object_data)
        })
        
        expect(response.status).to be(200)
        response_json = JSON.parse(response.body)
        expect(response_json).to eq({
          'success' => false,
          'errors' => ['Invalid digital_object_type specified: digital_object_type => {"string_key"=>"invalid_type"}']
        })
      end
      
      it "successfully creates an Item when the correct set of parameters are supplied" do
        request_spec_sign_in_admin_user()
        post(digital_objects_path, {
          digital_object_data_json: JSON.generate(sample_item_digital_object_data)
        })
        
        expect(response.status).to be(200)
        response_json = JSON.parse(response.body)
        expect(response_json['success']).to eq(true)
        expect(response_json['pid'].length).not_to eq(0)
      end
      
      describe "Create an Asset with attached file when the correct set of parameters are supplied" do
        
        it "works via post data upload (simulating browser form submission)" do
          request_spec_sign_in_admin_user()
          
          asset_digital_object_data = sample_asset_digital_object_data
          
          # Manually override import_file settings to set the fixture to type == post data
          asset_digital_object_data['import_file'] = {
            'import_type' => DigitalObject::Asset::IMPORT_TYPE_POST_DATA
          }
          
          post(digital_objects_path, {
            digital_object_data_json: JSON.generate(sample_asset_digital_object_data),
            file: fixture_file_upload('/sample_upload_files/lincoln.jpg', 'image/jpeg')
          })
          
          expect(response.status).to be(200)
          response_json = JSON.parse(response.body)
          expect(response_json['success']).to eq(true)
          expect(response_json['pid'].length).not_to eq(0)
        end
        
        it "works via *upload directory* filesystem upload, copying the target file to the internal Hyacinth data store" do
          skip 'todo'
        end
        
        it "works via filesystem upload (upload type: internal), copying the target file to the internal Hyacinth internal data store" do
          skip 'todo'
        end
        
        it "works via filesystem upload (upload type: external), referencing the target external file instead of copying the file to the Hyacinth internal data store" do
          skip 'todo'
        end
        
      end
    
    end


    describe "/digital_objects/search_results_to_csv.json" do
    
      let(:sample_item_as_csv_export) { CSV.parse( fixture('sample_digital_object_data/sample_item_as_csv_export.csv').read ) }
    
      before :example do
        
        puts 'running this before example...'
        
        # delete all current item records
        destroy_all_hyacinth_records()
        
        # create new item record
        post(digital_objects_path, {
          digital_object_data_json: JSON.generate(sample_item_digital_object_data)
        })
      end
    
      let(:response_status) { response.status }
      let(:response_json) { JSON.parse(response.body) }
      let(:export_id) { response_json['csv_export_id'] }
      let(:csv_export) { CsvExport.find(export_id) }
      # Get download location from csv_export record
      let(:path_to_csv_file) { csv_export.path_to_csv_file }
      let(:csv) { CSV.read(path_to_csv_file) }
      let(:generated_pid) { csv[1][0] }
      context "search request method is GET" do
        before { get search_results_to_csv_digital_objects_path, {format: 'json'} }

        it do
          expect(response_status).to be(200)
          expect(response_json['success']).to eq(true)
          expect(export_id).to be_a(Fixnum)
          # Text environment processes jobs immediately, so the export should be done and should have a status of "success"
          expect(csv_export.success?).to eq(true)
          expect(csv[0][0]).to eq('_pid')
          # The PID field is randomly generated, so we'll copy the pid from the result to the csv fixture that we're testing against
          sample_item_as_csv_export[1][0] = generated_pid
          expect(csv).to eq(sample_item_as_csv_export)
        end
      end
      
      context "search request method is POST" do
        before { post search_results_to_csv_digital_objects_path, {format: 'json'} }

        it do
          expect(response_status).to be(200)
          expect(response_json['success']).to eq(true)
          expect(export_id).to be_a(Fixnum)
          # Text environment processes jobs immediately, so the export should be done and should have a status of "success"
          expect(csv_export.success?).to eq(true)
          expect(csv[0][0]).to eq('_pid')
          # The PID field is randomly generated, so we'll copy the pid from the result to the csv fixture that we're testing against
          sample_item_as_csv_export[1][0] = generated_pid
          expect(csv).to eq(sample_item_as_csv_export)
        end
      end      
    end
  end
end
