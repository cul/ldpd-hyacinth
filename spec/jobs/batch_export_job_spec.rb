# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BatchExportJob, solr: true do
  subject(:batch_export) { FactoryBot.create(:batch_export) }
  let(:batch_export_id) { batch_export.id }

  let(:legend_of_lincoln_project) { FactoryBot.create(:project, :legend_of_lincoln) }
  let(:history_of_hamilton_project) { FactoryBot.create(:project, :history_of_hamilton) }

  context 'batch_export is successful' do
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

  context 'batch_export fails' do
    before do
      allow(JsonCsv).to receive(:create_csv_for_json_records).and_raise(StandardError)
      described_class.perform(batch_export_id)
      batch_export.reload
    end

    its(:status) { is_expected.to eq('failure') }
    its(:file_location) { is_expected.to be_blank }
    its(:export_errors) { is_expected.to be_present }
  end

  context 'batch export is not found' do
    it 'raises an error' do
      expect { described_class.perform(12_345) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
