require 'rails_helper'

describe "CSV Export-Import Round Trip" do

  before :example do
    # delete all current item records
    destroy_all_hyacinth_groups_items_and_assets()
  end

  describe "exporting objects to CSV and successfully reimporting them from the created CSV" do
    let(:group_digital_object_data) {
      JSON.parse( fixture('sample_digital_object_data/new_group.json').read )
    }

    let(:item_digital_object_data) {
      JSON.parse( fixture('sample_digital_object_data/new_item.json').read )
    }

    let(:asset_digital_object_data) {
      dod = JSON.parse( fixture('sample_digital_object_data/new_asset.json').read )
      file_path = File.join(fixture_path(), '/files/lincoln.jpg')
      # Manually override import_file settings in the dummy fixture
      dod['import_file'] = {
        'main' => {
          'import_type' => DigitalObject::Asset::IMPORT_TYPE_INTERNAL,
          'import_location' => file_path,
          'original_file_path' => file_path
        }
      }
      dod
    }

    it "works" do
      newly_created_digital_objects = []

      5.times do |i|

        ### Create group ###
        group_digital_object_data['identifiers'] = ["test:csv_export_import_group_#{i}"]
        group_digital_object_data['dynamic_field_data']['title'] = [
          {
            "title_sort_portion" => "Group #{i}",
            "title_non_sort_portion" => "The"
          }
        ]
        new_group = DigitalObjectType.get_model_for_string_key(group_digital_object_data['digital_object_type']['string_key']).new()
        new_group.set_digital_object_data(group_digital_object_data, false)
        new_group.save
        newly_created_digital_objects << new_group

        ### Create item ###
        item_digital_object_data['identifiers'] = ["test:csv_export_import_item_#{i}"]
        item_digital_object_data['dynamic_field_data']['title'] = [
          {
            "title_sort_portion" => "Item #{i}",
            "title_non_sort_portion" => "The"
          }
        ]
        # Make test:csv_export_import_group_0 the parent of test:csv_export_import_item_0,
        # test:csv_export_import_group_1 the parent of test:csv_export_import_item_1, etc.
        item_digital_object_data['parent_digital_objects'] = [
          {
            'identifier' => "test:csv_export_import_group_#{i}"
          }
        ]
        new_item = DigitalObjectType.get_model_for_string_key(item_digital_object_data['digital_object_type']['string_key']).new()
        new_item.set_digital_object_data(item_digital_object_data, false)
        new_item.save
        newly_created_digital_objects << new_item

        ### Create asset ###
        asset_digital_object_data['identifiers'] = ["test:csv_export_import_asset_#{i}"]
        asset_digital_object_data['dynamic_field_data']['title'] = [
          {
            "title_sort_portion" => "Asset #{i}",
            "title_non_sort_portion" => "The"
          }
        ]
        # Make test:csv_export_import_item_0 the parent of test:csv_export_import_asset_0,
        # test:csv_export_import_item_1 the parent of test:csv_export_import_asset_1, etc.
        asset_digital_object_data['parent_digital_objects'] = [
          {
            'identifier' => "test:csv_export_import_item_#{i}"
          }
        ]

        new_asset = DigitalObjectType.get_model_for_string_key(asset_digital_object_data['digital_object_type']['string_key']).new()
        new_asset.set_digital_object_data(asset_digital_object_data, false)
        new_asset.save
        newly_created_digital_objects << new_asset
      end

      # Create first CsvExport instance and process it immediately
      first_csv_export = CsvExport.create(
        user: User.find_by(is_admin: true), # Admin users have access to all records
        search_params: JSON.generate({
          'fq' => { 'hyacinth_type_si' => [{ 'does_not_equal' => 'publish_target' }] }
        })
      )
      ExportSearchResultsToCsvJob.perform_now(first_csv_export.id)
      first_csv_export.reload # Reload the ActiveRecord object, getting the latest data in the DB (so we have the path to the csv file)
      path_to_first_csv_file = first_csv_export.path_to_csv_file

      # Now we'll clear all DynamicFieldData, Publish Targets and Identifiers from the records
      newly_created_digital_objects.each do |digital_object|
        # Re-fetch the object so that we're not using a version that has previous file import data
        digital_object = DigitalObject::Base.find(digital_object.pid)
        digital_object.set_digital_object_data({
          'identifiers' => [], # Note: Clearing identifiers still leaves the pid as an identifier, which is fine
          'publish_targets' => [],
          'parent_digital_objects' => [],
          'dynamic_field_data' => {
            # A title is required, otherwise the object won't validate
            'title' => [
              {
                "title_sort_portion" => "---"
              }
            ]
          }
        }, false) # Do not merge with existing dynamic_field_data because we want to clear values
        digital_object.save
      end

      # And then we'll reimport the CSV to re-add all of the DynamicFieldData, Publish Targets and Identifiers from the records
      @import_job = Hyacinth::Utils::CsvImportExportUtils.create_import_job_from_csv_data(IO.read(path_to_first_csv_file), File.basename(path_to_first_csv_file), User.find_by(is_admin: true))

      expect(@import_job.errors.any?).to eq(false), "Expected no errors, but got: " + @import_job.errors.inspect

      # And we'll re-export to CSV and verify that the second CSV matches the first CSV

      # Create second CsvExport instance and process it immediately
      second_csv_export = CsvExport.create(
        user: User.find_by(is_admin: true), # Admin users have access to all records
        search_params: JSON.generate({
          'fq' => { 'hyacinth_type_si' => [{ 'does_not_equal' => 'publish_target' }] }
        })
      )
      ExportSearchResultsToCsvJob.perform_now(second_csv_export.id)
      second_csv_export.reload # Reload the ActiveRecord object, getting the latest data in the DB (so we have the path to the csv file)
      path_to_second_csv_file = second_csv_export.path_to_csv_file
      expect(CSV.read(path_to_first_csv_file)).to eq(CSV.read(path_to_second_csv_file))
    end
  end
end
