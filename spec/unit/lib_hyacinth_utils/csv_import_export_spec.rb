require 'rails_helper'

context 'Hyacinth::Utils::CsvImportExportUtils' do

  let(:digital_object_data) { JSON.parse( fixture('lib/hyacinth/utils/csv_import_export/sample_record.json').read ) }

  before(:context) do
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

end
