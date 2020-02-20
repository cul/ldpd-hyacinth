# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BatchExport, type: :model do
  describe '#new' do
    context 'when parameters are correct' do
      subject(:batch_export) { FactoryBot.create(:batch_export) }

      it { is_expected.to be_a BatchExport }
      its(:search_params) { is_expected.to eq '{"search":"true","f":{"project_display_label_sim":["University Seminars Digital Archive"]},"page":"1"}' }
      its(:user) { is_expected.to be_a User }
      its(:file_location) { is_expected.to be_nil }
      its(:export_errors) { is_expected.to eq [] }
      its(:status) { is_expected.to eq 'pending' }
      its(:duration) { is_expected.to eq 0 }
      its(:number_of_records_processed) { is_expected.to eq 0 }
      it 'has the expected created_at time' do
        Timecop.freeze do
          expect(batch_export.created_at).to eq(Time.current)
        end
      end
      it 'has the expected updated_at time' do
        Timecop.freeze do
          expect(batch_export.updated_at).to eq(Time.current)
        end
      end
    end
  end

  describe '#delete_associated_file_if_exist' do
    let(:file_location) { Tempfile.new(['temp', '.csv']).path }
    let(:batch_export) { FactoryBot.create(:batch_export, :success, file_location: "managed-disk://#{file_location}") }

    it 'runs after object destroy' do
      expect(batch_export).to receive(:delete_associated_file_if_exist)
      batch_export.destroy
    end

    it 'successfully deletes the associated file' do
      expect(File.exist?(file_location)).to be true
      batch_export.delete_associated_file_if_exist
      expect(File.exist?(file_location)).to be false
    end
  end
end
