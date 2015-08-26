require 'rails_helper'

context 'Hyacinth::Utils::CsvImportExportUtils' do

  before(:context) do
    @expected_digital_object_data = JSON.parse( fixture('lib/hyacinth/utils/csv_import_export/sample_record.json').read )
  end

  before(:example) do
    
  end

  describe ".csv_to_digital_object_data" do
    it "converts properly" do
      #@digital_object_data = Hyacinth::Utils::CsvImportExportUtils.csv_to_digital_object_data(fixture('lib/hyacinth/utils/csv_import_export/sample_record.csv').read)
      skip 'Implementation pending'
    end
  end

  describe ".process_internal_field_value" do
    it "works" do
      digital_object_data = {}
      value = 'abc:123'
      internal_field_header_name = '_pid'
      Hyacinth::Utils::CsvImportExportUtils.process_internal_field_value(digital_object_data, value, internal_field_header_name)
      
      expect(digital_object_data).to eq({'_pid' => ['abc:123']})
    end
  end

end
