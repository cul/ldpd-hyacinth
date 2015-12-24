require 'rails_helper'

describe ExportSearchResultsToCsvJob, :type => :unit do
  let(:doc1) do
    {'something' => ['thing'], 'dynamic_field_data' => {'characteristic' => 'value'}}
  end
  let(:doc2) do
    {'something' => ['thing','other'], 'dynamic_field_data' => {'characteristic' => 'value'}}
  end
  let(:user) { User.new }
  let(:search_params) { Hash.new }

  before do
    allow(DigitalObject::Base).to receive(:search_in_batches)
    .and_yield(doc1).and_yield(doc2)
  end

  describe '.map_temp_field_indexes' do
    let(:expected) do
      {
        '_pid' => 0,
        '_project.string_key' => 1,
        '_digital_object_type.string_key' => 2,
        '_something-1' => 3,
        'characteristic' => 4,
        '_something-2' => 5
      }
    end

    subject { ExportSearchResultsToCsvJob.map_temp_field_indexes(search_params, user) }

    it do
      is_expected.to eql expected
    end
  end

  describe '.sort_pointers' do
    let(:input) do
      {
        '_pid' => 0,
        '_project.string_key' => 1,
        '_digital_object_type.string_key' => 2,
        '_something-1' => 3,
        'characteristic' => 4,
        '_something-2' => 5
      }
    end
    let(:expected) {
      [
        '_pid', '_digital_object_type.string_key', '_project.string_key',
        '_something-1', '_something-2', 'characteristic'
      ]
    }
    subject do
      input.keys.sort(&ExportSearchResultsToCsvJob.method(:sort_pointers))
    end

    it { is_expected.to eql(expected) }
  end

  describe '.perform' do
    let(:export_id) { 'export-id' }
    let(:export) do
      export = CsvExport.new(user: user, search_params: '{}', id: export_id)
      allow(export).to receive(:path_to_csv_file=)
      export
    end

    before do
      allow(CsvExport).to receive(:find).with(export_id).and_return(export)
      HYACINTH['csv_export_directory'] ||= Dir.tmpdir
    end

    it do
      expect(export).to receive(:success!)
      expect(export).to receive(:save)
      described_class.perform(export_id)
    end
  end
end
