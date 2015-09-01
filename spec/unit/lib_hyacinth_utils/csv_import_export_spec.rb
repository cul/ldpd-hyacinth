require 'rails_helper'

context 'Hyacinth::Utils::CsvImportExportUtils' do
  
  let(:new_digital_object_data) { {} }
  
  let(:builder_path_test_object) {
    obj = {
      "name" => [
        {
           "name_value" => {
              "value" => "Salinger, J. D.",
              "uri" => "http://id.loc.gov/authorities/names/n50016589"
           },
           "name_role" => [
              {
                 "name_role_value" => {
                    "value" => "Author",
                    "uri" => "http://id.loc.gov/roles/123"
                 },
                 "name_role_type" => "text"
              }
           ]
        }
      ]
    }
  }
  
  before(:context) do
  end

  before(:example) do
  end

  describe ".csv_to_digital_object_data" do
    
    let(:expected_new_item) { JSON.parse( fixture('lib/hyacinth/utils/csv_import_export/csv_to_json/new_item_example.json').read ) }
    let(:expected_new_asset) { JSON.parse( fixture('lib/hyacinth/utils/csv_import_export/csv_to_json/new_asset_example.json').read ) }
    let(:expected_existing_item) { JSON.parse( fixture('lib/hyacinth/utils/csv_import_export/csv_to_json/existing_item_update_example.json').read ) }
    
    it "converts properly" do
      #@digital_object_data = Hyacinth::Utils::CsvImportExportUtils.csv_to_digital_object_data(fixture('lib/hyacinth/utils/csv_import_export/sample_record.csv').read)
      skip 'Implementation pending'
    end
  end

  describe ".process_internal_field_value" do

    it "properly handles a non-blank field value" do
      Hyacinth::Utils::CsvImportExportUtils.process_internal_field_value(new_digital_object_data, 'abc:123', '_pid')
      expect(new_digital_object_data).to eq({'_pid' => ['abc:123']})
    end
    
    it "properly handles a blank field value (as an empty string)" do
      Hyacinth::Utils::CsvImportExportUtils.process_internal_field_value(new_digital_object_data, '', '_pid')
      expect(new_digital_object_data).to eq({'_pid' => ['']})
    end
  end
  
  describe ".get_object_at_builder_path" do
    
    it "can find the value for a known path" do
      builder_path = ['name', 0, 'name_role', 0]
      expected = {
        "name_role_value" => {
          "value" => "Author",
          "uri" => "http://id.loc.gov/roles/123"
        },
        "name_role_type" => "text"
      }
      expect(Hyacinth::Utils::CsvImportExportUtils.get_object_at_builder_path(builder_path_test_object, builder_path)).to eq(expected)
    end
    
    it "returns nil when a path cannot be found" do
      builder_path = ['name', 0, 'WRONG', 0]
      expect(Hyacinth::Utils::CsvImportExportUtils.get_object_at_builder_path(builder_path_test_object, builder_path)).to eq(nil)
    end
    
    it "returns the given object if the supplied builder_path is an empty array" do
      builder_path = []
      expect(Hyacinth::Utils::CsvImportExportUtils.get_object_at_builder_path(builder_path_test_object, builder_path)).to eq(builder_path_test_object)
    end
    
  end
  
  describe ".put_object_at_builder_path" do
    
    describe "builder path requirements" do
      it "the given builder path cannot end with a numeric value (which would indicate an insertion at a specific array index)" do
        non_existent_path = ['name', 0]
        expect {
          Hyacinth::Utils::CsvImportExportUtils.put_object_at_builder_path(builder_path_test_object, non_existent_path, {'something' => 'cool'}, false)
        }.to raise_error('When adding an object, your builder path cannot end with a specific array index (e.g. ["a", 3]). Specify the location of an array object to append the new object to that array.')
      end
    end
    
    describe "working with non-existant target paths" do
      it "raises an exception if the given builder path doesn't exist and create_missing_path == false" do
        non_existent_path = ['banana', 4, 'chair']
        expect {
          Hyacinth::Utils::CsvImportExportUtils.put_object_at_builder_path(builder_path_test_object, non_existent_path, {'something' => 'cool'}, false)
        }.to raise_error('Path not found.  To create path, pass a value true to the create_missing_path method parameter.')
      end
      
      it "properly adds a simple top level element" do
        
        object_to_modify = {}
        builder_path = ['title']
        object_to_add = {
          "title_sort_portion" => "The",
          "title_non_sort_portion" => "Great Gatsby"
        }
        
        expected = {
          "title" => [
            {
              "title_sort_portion" => "The",
              "title_non_sort_portion" => "Great Gatsby"
            }
          ]
        }
        
        Hyacinth::Utils::CsvImportExportUtils.put_object_at_builder_path(object_to_modify, builder_path, object_to_add, true)
        
        expect(object_to_modify).to eq(expected)
      end
      
      it "properly adds TWO simple top level element of the same type when none existed at the start" do
        
        object_to_modify = {}
        builder_path = ['title']
        first_object_to_add = {
          "title_sort_portion" => "The",
          "title_non_sort_portion" => "Great Gatsby"
        }
        second_object_to_add = {
          "title_sort_portion" => "The",
          "title_non_sort_portion" => "Hobbit"
        }
        
        expected = {
          "title" => [
            {
              "title_sort_portion" => "The",
              "title_non_sort_portion" => "Great Gatsby"
            },
            {
              "title_sort_portion" => "The",
              "title_non_sort_portion" => "Hobbit"
            }
          ]
        }
        
        Hyacinth::Utils::CsvImportExportUtils.put_object_at_builder_path(object_to_modify, builder_path, first_object_to_add, true)
        Hyacinth::Utils::CsvImportExportUtils.put_object_at_builder_path(object_to_modify, builder_path, second_object_to_add, true)
        
        expect(object_to_modify).to eq(expected)
      end
      
      it "adds a doubly-nested object into an empty top level object" do
        
        object_to_modify = {}
        builder_path = ['location', 0, 'location_holding', 0, 'location_holding_sublocation']
        first_object_to_add = {
          "value" => "Some sublocation",
        }
        second_object_to_add = {
          "value" => "Another sublocation",
        }
        
        expected = {
          "location" => [
            {
              "location_holding" => [
                {
                  "location_holding_sublocation" => [
                    {
                      "value" => "Some sublocation"
                    },
                    {
                      "value" => "Another sublocation"
                    }
                  ]
                }
              ]
            }
          ]
        }
        
        Hyacinth::Utils::CsvImportExportUtils.put_object_at_builder_path(object_to_modify, builder_path, first_object_to_add, true)
        Hyacinth::Utils::CsvImportExportUtils.put_object_at_builder_path(object_to_modify, builder_path, second_object_to_add, true)
        
        expect(object_to_modify).to eq(expected)
      end
      
    end
    
    describe "working with existing target paths" do
      
      it "properly appends a new object to the target array at the given builder path" do
        valid_path = ['name', 0, 'name_role']
        new_object = {
          "name_role_value" => {
             "value" => "Groundskeeper",
             "uri" => "http://id.loc.gov/roles/zzz"
          },
          "name_role_type" => "text"
        }
        
        Hyacinth::Utils::CsvImportExportUtils.put_object_at_builder_path(builder_path_test_object, valid_path, new_object, false)
        array_at_specified_builder_path = Hyacinth::Utils::CsvImportExportUtils.get_object_at_builder_path(builder_path_test_object, valid_path)
        
        expect( array_at_specified_builder_path ).to include( new_object )
      end
      
    end
    
  end
  
  describe ".process_dynamic_field_value" do

    it "properly handles a non-blank field value" do
      
      skip 'Implementation pending'
      
      current_builder_path = []
      Hyacinth::Utils::CsvImportExportUtils.process_dynamic_field_value(new_digital_object_data, 'The', 'title:title_non_sort_portion', current_builder_path)
      Hyacinth::Utils::CsvImportExportUtils.process_dynamic_field_value(new_digital_object_data, 'Catcher in the Rye', 'title:title_sort_portion', current_builder_path)
      expected = {
        "title" => [
          {
            "title_sort_portion" => "The",
            "title_non_sort_portion" => "Catcher in the Rye"
          }
        ]
      }
      expect(new_digital_object_data).to equal(expected)
    end
    
    it "properly handles a blank field value (as an empty string)" do
      skip 'Implementation pending'
      #Hyacinth::Utils::CsvImportExportUtils.process_dynamic_field_value(new_digital_object_data, '', 'some_dynamic_field', [])
      #expect(new_digital_object_data).to eq({'some_dynamic_field' => ''})
    end
  end
  
  

end
