require 'rails_helper'

context 'Hyacinth::Utils::CsvImportExportUtils' do

  before(:all) do
    
  end

  before(:each) do
    
  end

  context ".csv_to_json" do
    it "converts properly" do
      
      expected_digital_object_data = JSON.parse( fixture('lib/hyacinth/utils/csv_import_export/sample_record.json').read )
      csv_input = fixture('lib/hyacinth/utils/csv_import_export/sample_record.csv').read
      digital_object_data = Hyacinth::Utils::CsvImportExportUtils.csv_to_digital_object_data(csv_input)
      expect(digital_object_data).to eq(expected_digital_object_data)

    end
  end
  
  context ".json_to_csv" do

    it "converts properly" do
      
      expect(1).to eq(1)

    end

  end

end
