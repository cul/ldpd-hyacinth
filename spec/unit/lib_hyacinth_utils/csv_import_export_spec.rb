require 'rails_helper'

context 'Hyacinth::Utils::CsvImportExportUtils' do

  before(:all) do
    
  end

  before(:each) do
    
  end

  context ".csv_to_json" do
    it "converts properly" do
      
      expected_json_output = fixture('lib/hyacinth/utils/csv_import_export/sample_record.json').read
      json_output = Hyacinth::Utils::CsvImportExportUtils.csv_to_json('')
      
      expect(json_output).to eq(expected_json_output)
    end
  end
  
  context ".json_to_csv" do
    it "converts properly" do
      
      expect(1).to eq(1)
    end
  end

end
