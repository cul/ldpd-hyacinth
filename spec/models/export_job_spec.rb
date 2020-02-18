# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExportJob, type: :model do
  describe '#new' do
    context 'when parameters are correct' do
      subject(:export_job) { FactoryBot.create(:export_job) }

      it { is_expected.to be_a ExportJob }
      its(:search_params) { is_expected.to eq '{"search":"true","f":{"project_display_label_sim":["University Seminars Digital Archive"]},"page":"1"}' }
      its(:user) { is_expected.to be_a User }
      its(:file_location) { is_expected.to be_nil }
      its(:export_errors) { is_expected.to eq [] }
      its(:status) { is_expected.to eq 'pending' }
      its(:duration) { is_expected.to eq 0 }
      its(:number_of_records_processed) { is_expected.to eq 0 }
      it 'has the expected created_at time' do
        Timecop.freeze do
          expect(export_job.created_at).to eq(Time.current)
        end
      end
      it 'has the expected updated_at time' do
        Timecop.freeze do
          expect(export_job.updated_at).to eq(Time.current)
        end
      end
    end
  end

  describe '#delete_associated_file_if_exist' do
    let(:file_location) { Tempfile.new(['temp', '.csv']).path }
    let(:export_job) { FactoryBot.create(:export_job, :success, file_location: "managed-disk://#{file_location}") }

    it 'runs after object destroy' do
      expect(export_job).to receive(:delete_associated_file_if_exist)
      export_job.destroy
    end

    it 'successfully deletes the associated file' do
      expect(File.exist?(file_location)).to be true
      export_job.delete_associated_file_if_exist
      expect(File.exist?(file_location)).to be false
    end
  end
end
