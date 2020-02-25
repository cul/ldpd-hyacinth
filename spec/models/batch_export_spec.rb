# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BatchExport, type: :model do
  describe '#new' do
    context 'when parameters are correct' do
      subject(:batch_export) { FactoryBot.create(:batch_export) }

      it { is_expected.to be_a BatchExport }
      its(:search_params) { is_expected.to eq '{"digital_object_type_ssi":["item"],"q":null}' }
      its(:user) { is_expected.to be_a User }
      its(:file_location) { is_expected.to be_nil }
      its(:export_errors) { is_expected.to eq [] }
      its(:status) { is_expected.to eq 'pending' }
      its(:duration) { is_expected.to eq 0 }
      its(:number_of_records_processed) { is_expected.to eq 0 }
      its(:total_records_to_process) { is_expected.to eq 0 }

      context "time-based tests" do
        before do
          # Must use (nsec: 0) below to work around Timecop nanosecond drift bug (that appears in Travis CI)
          # See: https://github.com/travisjeffery/timecop/issues/97#issuecomment-41294684
          Timecop.freeze(Time.current.change(nsec: 0))
        end
        after { Timecop.return }

        it 'has the expected created_at time' do
          expect(batch_export.created_at).to eq(Time.current)
        end
        it 'has the expected updated_at time' do
          expect(batch_export.updated_at).to eq(Time.current)
        end
      end
    end
  end

  describe '#delete_associated_file_if_exist' do
    let(:file_path) { Tempfile.new(['temp', '.csv']).path }
    let(:file_location) { "managed-disk://#{file_path}" }
    let(:batch_export) { FactoryBot.create(:batch_export, :success, file_location: file_location) }

    it 'runs after object destroy' do
      expect(batch_export).to receive(:delete_associated_file_if_exist)
      batch_export.destroy
    end

    it 'successfully deletes the associated file' do
      expect(File.exist?(file_path)).to be true
      batch_export.delete_associated_file_if_exist
      expect(File.exist?(file_path)).to be false
    end
  end
end
