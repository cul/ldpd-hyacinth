require 'rails_helper'

describe "CSV Export Import Round Trip Spec", focus: true do
  
  before :example do
    # delete all current item records
    destroy_all_hyacinth_records()
  end
  
  let(:sample_item_digital_object_data) {
    JSON.parse( fixture('sample_digital_object_data/new_item.json').read )
  }
  
  let(:sample_asset_digital_object_data) {
    dod = JSON.parse( fixture('sample_digital_object_data/new_asset.json').read )
    dod['identifiers'] = ['asset.' + SecureRandom.uuid] # random identifer to avoid collisions
    
    file_path = File.join(fixture_path(), '/sample_upload_files/lincoln.jpg')
    
    # Manually override import_file settings in the dummy fixture
    dod['import_file'] = {
      'import_type' => DigitalObject::Asset::IMPORT_TYPE_INTERNAL,
      'import_path' => file_path,
      'original_file_path' => file_path
    }
    
    dod
  }
  
  it "can export objects to CSV and successfully reimport them from the created CSV" do
    newly_created_items = []
    
    # Create some items
    10.times do |i|
      sample_item_digital_object_data['identifiers'] = ["test:csv_export_import_item_#{i}"]
      sample_item_digital_object_data['dynamic_field_data']['title'] = [
        {
          "title_sort_portion" => "Item #{i}",
          "title_non_sort_portion" => "The"
        }
      ]
      
      new_item = DigitalObjectType.get_model_for_string_key(sample_item_digital_object_data['digital_object_type']['string_key']).new()
      new_item.set_digital_object_data(sample_item_digital_object_data, false)
      new_item.save
      
      newly_created_items << new_item
    end
    
    # Create first CsvExport instance and process it immediately
    first_csv_export = CsvExport.create(
      user: User.find_by(is_admin: true), # Admin users have access to all records
      search_params: JSON.generate({'csv' => 'test'})
    )
    ExportSearchResultsToCsvJob.perform(first_csv_export.id)
    first_csv_export.reload # Reload the ActiveRecord object, getting the latest data in the DB (so we have the path to the csv file)
    path_to_first_csv_file = first_csv_export.path_to_csv_file
    
    # Now we'll clear all DynamicFieldData, Publish Targets and Identifiers from the records
    newly_created_items.each do |item|
      item.set_digital_object_data({
        'identifiers' => [], # Note: Clearing identifiers still leaves the pid as an identifier, which is fine
        'publish_targets' => [],
        'dynamic_field_data' => {
          # A title is required, otherwise the object won't validate
          'title' => [
            {
              "title_sort_portion" => "---"
            }
          ]
        }
      }, false) # Do not merge with existing dynamic_field_data because we want to clear values
      item.save
    end
    
    # And then we'll reimport the CSV to re-add all of the DynamicFieldData, Publish Targets and Identifiers from the records
    @import_job = Hyacinth::Utils::CsvImportExportUtils.create_import_job_from_csv_data(IO.read(path_to_first_csv_file), File.basename(path_to_first_csv_file), User.find_by(is_admin: true))
    puts 'Import errors: ' + @import_job.errors.inspect
    expect(@import_job.errors.any?).to eq(false)
    
    # And we'll re-export to CSV and verify that the second CSV matches the first CSV
    
    # Create second CsvExport instance and process it immediately
    second_csv_export = CsvExport.create(
      user: User.find_by(is_admin: true), # Admin users have access to all records
      search_params: JSON.generate({'csv' => 'test'})
    )
    ExportSearchResultsToCsvJob.perform(second_csv_export.id)
    second_csv_export.reload # Reload the ActiveRecord object, getting the latest data in the DB (so we have the path to the csv file)
    path_to_second_csv_file = second_csv_export.path_to_csv_file
    
    expect(CSV.read(path_to_first_csv_file)).to eq(CSV.read(path_to_second_csv_file))
  end
  
end