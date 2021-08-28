# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BatchExportJob do
  subject(:batch_export) { FactoryBot.create(:batch_export) }
  let(:batch_export_id) { batch_export.id }

  let(:legend_of_lincoln_project) { FactoryBot.create(:project, :legend_of_lincoln) }
  let(:history_of_hamilton_project) { FactoryBot.create(:project, :history_of_hamilton) }

  context 'batch_export is successful', solr: true do
    before do
      # Create some items
      2.times { FactoryBot.create(:item, primary_project: legend_of_lincoln_project) }
      2.times { FactoryBot.create(:item, primary_project: history_of_hamilton_project) }
      # Grant read permission to only one project for batch_export's user
      batch_export.user.permissions << Permission.new(
        action: Permission::PROJECT_ACTION_READ_OBJECTS,
        subject: Project.to_s,
        subject_id: legend_of_lincoln_project.id
      )

      described_class.perform(batch_export_id)
      batch_export.reload
    end

    its(:status) { is_expected.to eq('success') }
    its(:duration) { is_expected.to be_positive }
    its(:export_errors) { is_expected.to be_blank }
    its(:number_of_records_processed) do
      is_expected.to eq(2)
    end
    its(:total_records_to_process) do
      is_expected.to eq(2)
    end
    its(:file_location) { is_expected.to be_present }

    it 'has the expected content in the exported csv, only including items from projects that the user can read' do
      csv_data = CSV.parse(Hyacinth::Config.batch_export_storage.read(batch_export.file_location), headers: true)
      expect(csv_data.length).to eq(2)
      unique_project_string_keys = csv_data.map { |row| row['_primary_project.string_key'] }.uniq
      expect(unique_project_string_keys).to eq(['legend_of_lincoln'])
    end
  end

  context 'batch_export fails', solr: true do
    before do
      allow(JsonCsv).to receive(:create_csv_for_json_records).and_raise(StandardError)
      described_class.perform(batch_export_id)
      batch_export.reload
    end

    its(:status) { is_expected.to eq('failure') }
    its(:file_location) { is_expected.to be_blank }
    its(:export_errors) { is_expected.to be_present }
  end

  context 'batch export is not found', solr: true do
    it 'raises an error' do
      expect { described_class.perform(12_345) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context '.export_filter_from_config', solr: true do
    context 'when the given export_filter_config is blank' do
      let(:expected_export_filter) { Hyacinth::Jobs::BatchExportJob::ExportFilter.default_export_filter }
      let(:expected_inclusion_filters) { expected_export_filter.inclusion_filters }
      let(:expected_exclusion_filters) { expected_export_filter.exclusion_filters }

      [{}, nil].each do |val|
        it 'returns an export filter with the default inclusion and exclusion filters' do
          export_filter = described_class.export_filter_from_config(val)
          expect(export_filter.inclusion_filters).to eq(expected_inclusion_filters)
          expect(export_filter.exclusion_filters).to eq(expected_exclusion_filters)
        end
      end
    end

    context 'when a user supplies an export_filter_config with inclusion and exclusion filters' do
      let(:inclusion_filters) { ['_aaa'] }
      let(:exclusion_filters) { ['_zzz'] }
      let(:export_filter_config) do
        {
          'inclusion_filters' => inclusion_filters,
          'exclusion_filters' => exclusion_filters
        }
      end
      let(:export_filter) { described_class.export_filter_from_config(export_filter_config) }

      it 'returns an ExportFilter object that includes only the given inclusion filters' do
        expect(export_filter.inclusion_filters).to eq(inclusion_filters)
      end

      it 'returns an ExportFilter object that includes the given exclusion filters AND our default exclusion filters' do
        expect(export_filter.exclusion_filters).to eq(
          exclusion_filters + Hyacinth::Jobs::BatchExportJob::ExportFilter.default_exclusion_filters
        )
      end
    end
  end

  describe '.digital_object_as_export', solr: false do
    context 'with utf8 descriptive metadata values' do
      let(:authorized_object) do
        FactoryBot.build(:item, :with_rights, :with_utf8_title, :with_other_projects)
      end
      let(:json_data) { described_class.digital_object_as_export(authorized_object) }
      let(:actual_value) { json_data&.dig('_title', 'sort_portion') }
      # expected value ends in Cora\u00e7\u00e3o (67, 111, 114, 97, 231, 227, 111)
      let(:expected_value) { [80, 97, 114, 97, 32, 77, 97, 99, 104, 117, 99, 97, 114, 32, 77, 101, 117, 32, 67, 111, 114, 97, 231, 227, 111] }
      it "preserves utf-8 data" do
        expect(actual_value&.unpack('U*')).to eql(expected_value)
      end
    end
  end
end
