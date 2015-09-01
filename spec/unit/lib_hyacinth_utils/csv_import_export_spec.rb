require 'rails_helper'

context 'Hyacinth::Utils::CsvImportExportUtils' do

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
    let(:digital_object_data) { {} }

    it "properly handles a non-blank field value" do
      Hyacinth::Utils::CsvImportExportUtils.process_internal_field_value(digital_object_data, 'abc:123', '_pid')
      expect(digital_object_data).to eq({'_pid' => ['abc:123']})
    end
    
    it "properly handles a blank field value" do
      Hyacinth::Utils::CsvImportExportUtils.process_internal_field_value(digital_object_data, '', '_pid')
      expect(digital_object_data).to eq({})
    end
  end
  
  describe ".process_dynamic_field_value" do
    let(:digital_object_data) { {} }

    it "properly handles a non-blank field value" do
      skip 'Implementation pending'
    end
    
    it "properly handles a blank field value" do
      Hyacinth::Utils::CsvImportExportUtils.process_dynamic_field_value(digital_object_data, '', 'some_dynamic_field', [])
      expect(digital_object_data).to eq({})
    end
  end

end
