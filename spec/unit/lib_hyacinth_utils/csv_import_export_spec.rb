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
    let(:expected_multiple_digital_objects) { JSON.parse( fixture('lib/hyacinth/utils/csv_import_export/csv_to_json/multiple_digital_objects_example.json').read ) }
    
    let(:expected_new_item_csv_data) { fixture('lib/hyacinth/utils/csv_import_export/csv_to_json/new_item_example.csv').read }
    let(:expected_new_asset_csv_data) { fixture('lib/hyacinth/utils/csv_import_export/csv_to_json/new_asset_example.csv').read }
    let(:expected_existing_item_csv_data) { fixture('lib/hyacinth/utils/csv_import_export/csv_to_json/existing_item_update_example.csv').read }
    let(:expected_multiple_digital_objects_csv_data) { fixture('lib/hyacinth/utils/csv_import_export/csv_to_json/multiple_digital_objects_example.csv').read }
    
    it "converts properly for a new item" do
      Hyacinth::Utils::CsvImportExportUtils.csv_to_digital_object_data(expected_new_item_csv_data) do |digital_object_data|
        expect(digital_object_data).to eq(expected_new_item)
      end
    end
    
    it "converts properly for a new asset" do
      Hyacinth::Utils::CsvImportExportUtils.csv_to_digital_object_data(expected_new_asset_csv_data) do |digital_object_data|
        expect(digital_object_data).to eq(expected_new_asset)
      end
    end
    
    it "converts properly for an existing item" do
      Hyacinth::Utils::CsvImportExportUtils.csv_to_digital_object_data(expected_existing_item_csv_data) do |digital_object_data|
        expect(digital_object_data).to eq(expected_existing_item)
      end
    end
    
    it "converts properly for multiple digital objects in the same spreadsheet" do
      
      counter = 0
      
      Hyacinth::Utils::CsvImportExportUtils.csv_to_digital_object_data(expected_multiple_digital_objects_csv_data) do |digital_object_data|
        expect(digital_object_data).to eq(expected_multiple_digital_objects[counter])
        counter += 1
      end
      
    end
    
  end

  describe ".process_internal_field_value" do
    
    
    it "raises an exception if a supplied field name does not begin with an underscore ('_')" do
      expect {
        Hyacinth::Utils::CsvImportExportUtils.process_internal_field_value(new_digital_object_data, 'zzz', 'field_name_that_does_not_start_with_an_underscore')
      }.to raise_error("Internal field header names must begin with an underscore ('_')")
    end

    it "properly handles a non-blank field value" do
      Hyacinth::Utils::CsvImportExportUtils.process_internal_field_value(new_digital_object_data, 'abc:123', '_pid')
      expect(new_digital_object_data).to eq({'pid' => 'abc:123'})
    end
    
    it "properly handles a non-blank field value that uses dot-notation" do
      Hyacinth::Utils::CsvImportExportUtils.process_internal_field_value(new_digital_object_data, 'item', '_type.string_key')
      expect(new_digital_object_data).to eq(
        {
          'type' => {
            'string_key' => 'item'
          }
        }
      )
    end
    
    it "properly handles a blank field value for a simple field name" do
      Hyacinth::Utils::CsvImportExportUtils.process_internal_field_value(new_digital_object_data, '', '_pid')
      expect(new_digital_object_data).to eq({'pid' => ''})
    end
    
    it "properly handles a blank field value for a multivalued field" do
      Hyacinth::Utils::CsvImportExportUtils.process_internal_field_value(new_digital_object_data, '', '_identifier-1')
      Hyacinth::Utils::CsvImportExportUtils.process_internal_field_value(new_digital_object_data, '', '_identifier-2')
      expect(new_digital_object_data).to eq({'identifier' => ['', '']})
    end
    
    it "properly handles a blank field value for a multivalued field that uses dot-notation" do
      Hyacinth::Utils::CsvImportExportUtils.process_internal_field_value(new_digital_object_data, '', '_publish_target-1.string_key')
      Hyacinth::Utils::CsvImportExportUtils.process_internal_field_value(new_digital_object_data, '', '_publish_target-2.string_key')
      expect(new_digital_object_data).to eq(
        {
          'publish_target' => [
            {
              'string_key' => ''
            },
            {
              'string_key' => ''
            }
          ]
        }
      )
    end
    
    it "raises an exception if a 0-indexed internal field header is supplied (because headers should be 1-indexed)" do
      current_builder_path = []
      expect {
        Hyacinth::Utils::CsvImportExportUtils.process_internal_field_value(new_digital_object_data, 'value', '_publish_target-0.string_key')
      }.to raise_error('Internal field header names cannot be 0-indexed. Must be 1-indexed.')
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
    
    describe "working with non-existant target paths" do
      it "raises an exception if the given builder path doesn't exist and create_missing_path == false" do
        non_existent_path = ['banana', 4, 'chair']
        expect {
          Hyacinth::Utils::CsvImportExportUtils.put_object_at_builder_path(builder_path_test_object, non_existent_path, {'something' => 'cool'}, false)
        }.to raise_error('Path not found.  To create path, pass a value true to the create_missing_path method parameter.')
      end
      
      it "properly adds a simple top level element to a hash" do
        
        object_to_modify = {}
        builder_path = ['title']
        object_to_add = {
          "title_sort_portion" => "The",
          "title_non_sort_portion" => "Great Gatsby"
        }
        
        expected = {
          "title" =>  {
            "title_sort_portion" => "The",
            "title_non_sort_portion" => "Great Gatsby"
          }
        }
        
        Hyacinth::Utils::CsvImportExportUtils.put_object_at_builder_path(object_to_modify, builder_path, object_to_add, true)
        
        expect(object_to_modify).to eq(expected)
      end
      
      it "properly adds a simple top level element to an array" do
        
        object_to_modify = []
        builder_path = [0]
        object_to_add = {
          "title_sort_portion" => "The",
          "title_non_sort_portion" => "Great Gatsby"
        }
        
        expected = [
          {
            "title_sort_portion" => "The",
            "title_non_sort_portion" => "Great Gatsby"
          }
        ]
        
        Hyacinth::Utils::CsvImportExportUtils.put_object_at_builder_path(object_to_modify, builder_path, object_to_add, true)
        
        expect(object_to_modify).to eq(expected)
      end
      
      it "can create a set of nested hashes for a non-existant path" do
        
        object_to_modify = {}
        builder_path = ['a', 'b', 'c', 'd']
        object_to_add = 'zzz'
        
        expected = {
          "a" =>  {
            "b" => {
              "c" => {
                "d" => object_to_add
              }
            }
          }
        }

        Hyacinth::Utils::CsvImportExportUtils.put_object_at_builder_path(object_to_modify, builder_path, object_to_add, true)
        expect(object_to_modify).to eq(expected)
      end
      
      it "can create a set of nested arrays for a non-existant path" do
        
        object_to_modify = []
        builder_path = [0, 0, 0, 0]
        object_to_add = 'aaa'
        
        expected = [
          [
            [
              [
                object_to_add
              ]
            ]
          ]
        ]

        Hyacinth::Utils::CsvImportExportUtils.put_object_at_builder_path(object_to_modify, builder_path, object_to_add, true)
        expect(object_to_modify).to eq(expected)
      end
      
      it "can add two new elements to the same array at the specified indexes" do
        
        object_to_modify = {}
        builder_path_1 = ['title', 1]
        obj1 = {
          "title_sort_portion" => "The",
          "title_non_sort_portion" => "Great Gatsby"
        }
        builder_path_2 = ['title', 0]
        obj2 = {
          "title_sort_portion" => "The",
          "title_non_sort_portion" => "Hobbit"
        }
        
        expected = {
          "title" => [
            {
              "title_sort_portion" => "The",
              "title_non_sort_portion" => "Hobbit"
            },
            {
              "title_sort_portion" => "The",
              "title_non_sort_portion" => "Great Gatsby"
            }
          ]
        }
        
        Hyacinth::Utils::CsvImportExportUtils.put_object_at_builder_path(object_to_modify, builder_path_1, obj1, true)
        Hyacinth::Utils::CsvImportExportUtils.put_object_at_builder_path(object_to_modify, builder_path_2, obj2, true)
        
        expect(object_to_modify).to eq(expected)
      end
      
      it "can add a doubly-nested object into an empty top level object" do
        
        object_to_modify = {}
        builder_path_1 = ['location', 0, 'location_holding', 0, 'location_holding_sublocation', 1]
        builder_path_2 = ['location', 0, 'location_holding', 0, 'location_holding_sublocation', 0]
        obj1 = {
          "value" => "Some sublocation",
        }
        obj2 = {
          "value" => "Another sublocation",
        }
        
        expected = {
          "location" => [
            {
              "location_holding" => [
                {
                  "location_holding_sublocation" => [
                    {
                      "value" => "Another sublocation"
                    },
                    {
                      "value" => "Some sublocation"
                    }
                  ]
                }
              ]
            }
          ]
        }
        
        Hyacinth::Utils::CsvImportExportUtils.put_object_at_builder_path(object_to_modify, builder_path_1, obj1, true)
        Hyacinth::Utils::CsvImportExportUtils.put_object_at_builder_path(object_to_modify, builder_path_2, obj2, true)
        
        expect(object_to_modify).to eq(expected)
      end
      
      it "adds a key to an existing hash" do
        valid_path = ['name', 1, 'name_role', 0, 'name_role_value']
        two_name_object = {
          "name" => [
            {
              "name_role" => [
                {
                   "name_role_type" => "type1"
                }
              ]
            },
            {
              "name_role" => [
                {
                   "name_role_type" => "type2"
                }
              ]
            }
          ]
        }
        expected = {
          "name" => [
            {
              "name_role" => [
                {
                   "name_role_type" => "type1"
                }
              ]
            },
            {
              "name_role" => [
                {
                  "name_role_value" => "value1",
                  "name_role_type" => "type2"
                }
              ]
            }
          ]
        }
        Hyacinth::Utils::CsvImportExportUtils.put_object_at_builder_path(two_name_object, valid_path, 'value1', true)
        expect( two_name_object ).to eq( expected )
      end
      
    end
    
    describe "working with existing target paths" do
      
      it "raises an exception if it attempts to access a hash index at an array" do
        
        object_to_modify = []
        builder_path = ['title']
        object_to_add = {
          "key" => "value"
        }
        
        expect {
          Hyacinth::Utils::CsvImportExportUtils.put_object_at_builder_path(object_to_modify, builder_path, object_to_add, true)
        }.to raise_error
        
      end
      
      it "replaces an existing hash element with a new value" do
        valid_path = ['name', 1, 'name_role', 0, 'name_role_type']
        two_name_object = {
          "name" => [
            {
              "name_role" => [
                {
                   "name_role_type" => "type1"
                }
              ]
            },
            {
              "name_role" => [
                {
                   "name_role_type" => "type2"
                }
              ]
            }
          ]
        }
        expected = {
          "name" => [
            {
              "name_role" => [
                {
                   "name_role_type" => "type1"
                }
              ]
            },
            {
              "name_role" => [
                {
                   "name_role_type" => "type3"
                }
              ]
            }
          ]
        }
        Hyacinth::Utils::CsvImportExportUtils.put_object_at_builder_path(two_name_object, valid_path, 'type3', false)
        expect( two_name_object ).to eq( expected )
      end
      
      it "replaces an existing array element with a new value" do
        valid_path = ['name', 1, 'name_role', 0]
        two_name_object = {
          "name" => [
            {
              "name_role" => [
                {
                   "name_role_type" => "type1"
                }
              ]
            },
            {
              "name_role" => [
                {
                   "name_role_type" => "type2"
                }
              ]
            }
          ]
        }
        new_value = [
          {
            "name_other_field" => "other_value"
          }
        ]
        Hyacinth::Utils::CsvImportExportUtils.put_object_at_builder_path(two_name_object, valid_path, new_value, false)
        expect( two_name_object['name'][1]['name_role'][0] ).to eq( new_value )
      end
      
    end
    
  end
  
  describe ".process_dynamic_field_value" do

    it "properly handles a non-blank field value" do
      current_builder_path = []
      Hyacinth::Utils::CsvImportExportUtils.process_dynamic_field_value(new_digital_object_data, 'The', 'title-1:title_non_sort_portion', current_builder_path)
      Hyacinth::Utils::CsvImportExportUtils.process_dynamic_field_value(new_digital_object_data, 'Catcher in the Rye', 'title-1:title_sort_portion', current_builder_path)
      expected = {
        "dynamic_field_data" => {
          "title" => [
            {
              "title_non_sort_portion" => "The",
              "title_sort_portion" => "Catcher in the Rye"
            }
          ]
        }
      }
      expect(new_digital_object_data).to eq(expected)
    end
    
    it "properly handles a dot-notated field" do
      current_builder_path = []
      Hyacinth::Utils::CsvImportExportUtils.process_dynamic_field_value(new_digital_object_data, 'Salinger, J. D.', 'name-1:name_value.value', current_builder_path)
      Hyacinth::Utils::CsvImportExportUtils.process_dynamic_field_value(new_digital_object_data, 'http://id.loc.gov/authorities/names/n50016589', 'name-1:name_value.uri', current_builder_path)
      expected = {
        "dynamic_field_data" => {
          "name" => [
            {
              "name_value" => {
                "value" => "Salinger, J. D.",
                "uri" => "http://id.loc.gov/authorities/names/n50016589"
              }
            }
          ]
        }
      }
      expect(new_digital_object_data).to eq(expected)
    end
    
    it "properly handles a blank field value (as an empty string)" do
      current_builder_path = []
      Hyacinth::Utils::CsvImportExportUtils.process_dynamic_field_value(new_digital_object_data, '', 'title-1:title_sort_portion', current_builder_path)
      expected = {
        "dynamic_field_data" => {
          "title" => [
            {
              "title_sort_portion" => ""
            }
          ]
        }
      }
      expect(new_digital_object_data).to eq(expected)
    end
    
    it "raises an exception if a 0-indexed dynamic field header is supplied (because headers should be 1-indexed)" do
      current_builder_path = []
      expect {
        Hyacinth::Utils::CsvImportExportUtils.process_dynamic_field_value(new_digital_object_data, 'Catcher in the Rye', 'title-0:title_sort_portion', current_builder_path)
      }.to raise_error('Dynamic field header names cannot be 0-indexed. Must be 1-indexed.')
    end
  end
  
  

end
