# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BatchImport, type: :model do
  describe '#new' do
    subject(:batch_import) { FactoryBot.create(:batch_import, :with_digital_object_import) }

    it { is_expected.to be_a BatchImport }
    its(:priority)      { is_expected.to eql 'high' }
    its(:user)          { is_expected.to be_a User }
    its(:file_location) { 'managed-disk://path/to/file' }
    its(:cancelled)     { is_expected.to be false }

    its(:original_filename) { is_expected.to eql 'import.csv' }
    its('digital_object_imports.length') { is_expected.to be 1 }

    its(:status) { is_expected.to eql 'in_progress' }
  end

  describe '#delete_associated_file' do
    let(:file_location) { Tempfile.new(['temp', '.csv']).path }
    let(:batch_import) { FactoryBot.create(:batch_import, file_location: "managed-disk://#{file_location}") }

    it 'runs after object destroy' do
      expect(batch_import).to receive(:delete_associated_file)
      batch_import.destroy
    end

    it 'successfully deletes the associated file' do
      expect(File.exist?(file_location)).to be true
      batch_import.delete_associated_file
      expect(File.exist?(file_location)).to be false
    end
  end

  describe '#import_count' do
    let(:batch_import) { FactoryBot.create(:batch_import, :with_digital_object_import) }

    before do
      FactoryBot.create(:digital_object_import, :success, batch_import: batch_import)
      FactoryBot.create(:digital_object_import, :in_progress, batch_import: batch_import)
      FactoryBot.create(:digital_object_import, :pending, batch_import: batch_import)
    end

    it "returns 0 when counting failure imports" do
      expect(batch_import.import_count('failure')).to be 0
    end

    it "returns 1 when counting successful imports" do
      expect(batch_import.import_count('success')).to be 1
    end

    it "returns 1 when counting pending imports" do
      expect(batch_import.import_count('pending')).to be 1
    end

    it "returns 2 when counting in progress imports" do
      expect(batch_import.import_count('in_progress')).to be 2
    end
  end

  describe '#status' do
    subject { batch_import.status }

    let(:batch_import) { FactoryBot.create(:batch_import) }

    context 'when there are no digital object imports' do
      it 'returns pending' do
        is_expected.to eql 'pending'
      end
    end

    context 'when all digital object imports are successful' do
      before do
        FactoryBot.create(:digital_object_import, :success, batch_import: batch_import)
      end

      it 'returns success' do
        is_expected.to eql 'completed_successfully'
      end
    end

    context 'when at least one digital_object_import is in progress' do
      before do
        FactoryBot.create(:digital_object_import, :in_progress, batch_import: batch_import)
        FactoryBot.create(:digital_object_import, :pending, batch_import: batch_import)
        FactoryBot.create(:digital_object_import, :failure, batch_import: batch_import)
      end

      it 'returns in progress' do
        is_expected.to eql 'in_progress'
      end
    end

    context 'when at leat one digital_object_import is pending' do
      before do
        FactoryBot.create(:digital_object_import, :pending, batch_import: batch_import)
        FactoryBot.create(:digital_object_import, :failure, batch_import: batch_import)
        FactoryBot.create(:digital_object_import, :success, batch_import: batch_import)
      end

      it 'returns pending' do
        is_expected.to eql 'pending'
      end
    end

    context 'when all jobs are complete but at least one has failed' do
      before do
        FactoryBot.create(:digital_object_import, :failure, batch_import: batch_import)
        FactoryBot.create(:digital_object_import, :success, batch_import: batch_import)
      end

      it 'returns completed with failures' do
        is_expected.to eql 'complete_with_failures'
      end
    end

    context 'when job has been cancelled' do
      before do
        batch_import.cancelled = true
      end

      it 'returns cancelled' do
        is_expected.to eql 'cancelled'
      end
    end
  end

  describe '#destroy' do
    context 'when batch_import contains associated digital_object_imports' do
      let(:batch_import) { FactoryBot.create(:batch_import, :with_successful_digital_object_import) }
      let!(:digital_object_import_id) { batch_import.digital_object_imports.first.id }

      before { batch_import.destroy }

      it 'destroys both batch_import and child digital_object_imports' do
        expect(DigitalObjectImport.exists?(digital_object_import_id)).to be false
      end
    end
  end

  describe '#destroy!' do
    context 'when batch import is cancelled' do
      let(:batch_import) { FactoryBot.create(:batch_import, cancelled: true) }

      context 'with in progress imports' do
        before do
          FactoryBot.create(:digital_object_import, :in_progress, batch_import: batch_import)
        end

        it 'returns error' do
          expect { batch_import.destroy! }.to raise_error ActiveRecord::RecordNotDestroyed
        end
      end

      context 'when pending imports' do
        before do
          FactoryBot.create(:digital_object_import, :pending, batch_import: batch_import)
          batch_import.destroy!
        end

        it 'destroys batch import' do
          expect(batch_import.destroyed?).to be true
        end
      end
    end

    context 'when batch import is not cancelled' do
      let(:batch_import) { FactoryBot.create(:batch_import) }

      context 'with imports in_progress and pending' do
        before do
          FactoryBot.create(:digital_object_import, :pending, batch_import: batch_import)
          FactoryBot.create(:digital_object_import, :in_progress, batch_import: batch_import)
        end

        it 'returns error' do
          expect { batch_import.destroy! }.to raise_error ActiveRecord::RecordNotDestroyed
        end
      end

      context 'with imports in_progress' do
        before do
          FactoryBot.create(:digital_object_import, :in_progress, batch_import: batch_import)
        end

        it 'returns error' do
          expect { batch_import.destroy! }.to raise_error ActiveRecord::RecordNotDestroyed
        end
      end

      context 'with imports pending' do
        before do
          FactoryBot.create(:digital_object_import, :pending, batch_import: batch_import)
        end

        it 'returns error' do
          expect { batch_import.destroy! }.to raise_error ActiveRecord::RecordNotDestroyed
        end
      end

      context 'without any imports' do
        it 'destroys batch import' do
          batch_import.destroy!
          expect(batch_import.destroyed?).to be true
        end
      end

      context 'with successful and failed imports' do
        before do
          FactoryBot.create(:digital_object_import, :success, batch_import: batch_import)
          FactoryBot.create(:digital_object_import, :failure, batch_import: batch_import)
          batch_import.destroy!
        end

        it 'destroys batch import' do
          expect(batch_import.destroyed?).to be true
        end
      end
    end
  end

  describe '#csv_without_successful_imports' do
    context 'when file_location not present' do
      let(:batch_import) { FactoryBot.create(:batch_import, file_location: nil) }

      it 'raises error' do
        expect {
          batch_import.csv_without_successful_imports
        }.to raise_error 'Cannot generate csv without successful rows without file_location'
      end
    end

    context 'when file_location present' do
      let(:batch_import) { FactoryBot.create(:batch_import) }
      let(:original_csv) do
        <<~CSV
          _id,abstract.0.value,date_created.value
          12,abstract number 1,1984
          34,abstract number 2,1990
          45,abstract number 3,1976
          67,abstract number 4,1981
          89,abstract number 5,1984
        CSV
      end
      let(:active_storage_blob) do
        blob = ActiveStorage::Blob.create_before_direct_upload!(
          filename: 'import.csv',
          byte_size: original_csv.bytesize,
          checksum: Digest::MD5.hexdigest(original_csv),
          content_type: 'text/csv'
        )
        blob.upload(StringIO.new(original_csv))
        blob
      end
      let(:csv_without_success) do
        <<~CSV
          _id,abstract.0.value,date_created.value
          34,abstract number 2,1990
          45,abstract number 3,1976
          89,abstract number 5,1984
        CSV
      end

      before do
        batch_import.add_blob(active_storage_blob)

        FactoryBot.create(:digital_object_import, :success, batch_import: batch_import, index: 2)
        FactoryBot.create(:digital_object_import, :in_progress, batch_import: batch_import, index: 3)
        FactoryBot.create(:digital_object_import, :pending, batch_import: batch_import, index: 4)
        FactoryBot.create(:digital_object_import, :success, batch_import: batch_import, index: 5)
        FactoryBot.create(:digital_object_import, :failure, batch_import: batch_import, index: 6)

        batch_import.save!
      end

      it 'returns expected csv' do
        expect(batch_import.csv_without_successful_imports).to eql(csv_without_success)
      end
    end
  end
end
