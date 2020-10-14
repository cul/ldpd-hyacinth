# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Hyacinth::Jobs::BatchExportJob::ExportFilter do
  let(:inclusion_filters) { ['important', /keep\..+/, 'also_important'] }
  let(:exclusion_filters) { ['do_not_want', /ignore\..+/, 'bad'] }
  let(:instance) do
    described_class.new(inclusion_filters: inclusion_filters, exclusion_filters: exclusion_filters)
  end

  context '.default_export_filter' do
    it 'returns a valid object' do
      expect(described_class.default_export_filter).to be_a(described_class)
    end
  end

  context '.all_descriptive_metadata_field_filters' do
    before do
      FactoryBot.create(:dynamic_field_group)
    end
    let(:expected_filters) do
      [
        /name\[\d+\]\..+/
      ]
    end
    it 'returns the expected filters' do
      expect(described_class.all_descriptive_metadata_field_filters).to eq(expected_filters)
    end
  end

  context '.new' do
    it 'creates a valid object' do
      expect(instance).to be_a(described_class)
    end
    it 'assigns the expected inclusion_filters' do
      expect(instance.inclusion_filters).to eq(inclusion_filters)
    end
    it 'assigns the expected exclusion_filters' do
      expect(instance.exclusion_filters).to eq(exclusion_filters)
    end
    context 'no-arguments passed' do
      let(:instance) do
        described_class.new
      end
      it 'has empty array inclusion and exclusion filters' do
        expect(instance.inclusion_filters).to eq([])
        expect(instance.exclusion_filters).to eq([])
      end
    end
  end

  context '#header_matches_filters?' do
    context 'when header matches inclusion filter and does not match exclusion filter' do
      let(:inclusion_filters) { ['_uid'] }
      let(:exclusion_filters) { ['_zzz'] }
      let(:header) { '_uid' }
      it 'returns true' do
        expect(instance.header_matches_filters?(header)).to eq(true)
      end
    end

    context 'when header matches inclusion filter and also matches exclusion filter' do
      let(:inclusion_filters) { ['_uid'] }
      let(:exclusion_filters) { [/.*ui.*/] }
      let(:header) { '_uid' }
      it 'returns false' do
        expect(instance.header_matches_filters?(header)).to eq(false)
      end
    end

    context 'when header does not match inclusion filter and there are no exclusion filters' do
      let(:inclusion_filters) { ['_zzz'] }
      let(:exclusion_filters) { [] }
      let(:header) { '_uid' }
      it 'returns false' do
        expect(instance.header_matches_filters?(header)).to eq(false)
      end
    end
  end

  context '#indexes_of_headers_to_keep' do
    let(:inclusion_filters) { ['_uid', /.*_and_.*/] }
    let(:exclusion_filters) { ['_zzz'] }
    let(:headers) { ['a', '_uid', 'hall_and_oates', 'zzz'] }
    it 'returns the expected indexes' do
      expect(instance.indexes_of_headers_to_keep(headers)).to eq([1, 2])
    end
  end

  context '#generate_filtered_export' do
    let(:pre_filter_csv_path) { file_fixture('files/batch_export_filter/pre_filter.csv') }
    let(:expected_post_filter_csv_path) { file_fixture('files/batch_export_filter/post_filter.csv') }
    it 'filters as expected' do
      generated_filtered_csv = Tempfile.new('temp-out-file')
      instance.generate_filtered_export(pre_filter_csv_path, generated_filtered_csv)
      expect(FileUtils.identical?(generated_filtered_csv, expected_post_filter_csv_path)).to eq(true)
    ensure
      generated_filtered_csv.close!
    end
  end
end
