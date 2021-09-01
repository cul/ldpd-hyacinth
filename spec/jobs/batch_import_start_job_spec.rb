# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BatchImportStartJob, solr: true do
  let(:batch_import) do
    FactoryBot.create(
      :batch_import,
      file_location: "managed-disk://#{Rails.root.join('spec', 'fixtures', 'files', 'batch_import', 'sample-batch-import.csv')}"
    )
  end

  context '.perform' do
    before do
      # Create an item with an expected uid that one of the csv rows will update
      FactoryBot.create(:item, uid: '2f4e2917-26f5-4d8f-968c-a4015b10e50f')
    end

    context "with stubbed Resque.enqueue method to simulate normal asynchronous processing (and focus just on setup)" do
      before do
        # We don't want Resque.enqueue to process anything immediately for these tests (which is the
        # default behavior for our test environment), since we're not testing the queued job code.
        # So we'll stub the enqueue method for .perform tests, and we'll check for calls to enqueue in a test.
        allow(Resque).to receive(:enqueue)

        # Run import
        described_class.perform(batch_import.id)
      end

      it "creates the expected DigitalObjectImports and ImportPrerequisites" do
        expect(DigitalObjectImport.count).to eq(5)
        expect(ImportPrerequisite.count).to eq(4)
      end

      it "enqueues the expected DigitalObjectImports" do
        expect(Resque).to have_received(:enqueue).with(DigitalObjectImportProcessingJob, 1)
        expect(Resque).to have_received(:enqueue).with(DigitalObjectImportProcessingJob, 5)
      end

      it "sets the status of only expected DigitalObjectImports to 'queued'" do
        expect(
          DigitalObjectImport.order(:index).map(&:status)
        ).to eq(['queued', 'pending', 'pending', 'pending', 'queued'])
      end
    end

    context "with synchronous processing of jobs" do
      before do
        DynamicFieldsHelper.enable_dynamic_fields('item', Project.find_by_string_key('great_project'))
        DynamicFieldsHelper.enable_dynamic_fields('asset', Project.find_by_string_key('great_project'))
        described_class.perform(batch_import.id)
        batch_import.reload
        expect(batch_import.setup_errors).to be_blank
      end
      it "runs successfully, without errors, and creates the correct number of objects" do
        # This is a slow test, so that's why we're checking multiple things in the same test.
        # Expect all DigitalObjectImports to be successful
        expect(DigitalObjectImport.all.pluck(:status).uniq).to eq(['success']), lambda {
          "Expected success status for all imports, but encountered some failures. More info: \n" +
            DigitalObjectImport.where.not(status: 'success').map { |import| "Row #{import.index} had error(s): #{import.import_errors.join(', ')}" }.join("\n")
        }
        # Expect no remaining ImportPrerequisite because they've all been processed
        expect(ImportPrerequisite.count).to eq(0)
        # Expect that all records have been created
        expect(DigitalObject.count).to eq(5)
        expect(batch_import.status).to eq(BatchImport::COMPLETED_SUCCESSFULLY)
      end
    end
  end

  context '.process_csv_file_if_present' do
    context "for a batch_import with NO file_location value" do
      it 'returns early and does nothing ' do
        expect(Hyacinth::Config.batch_import_storage).not_to receive(:with_readable_tempfile)
        batch_import.file_location = nil
        described_class.process_csv_file_if_present(batch_import)
      end
    end

    context "for a batch_import with a file_location value" do
      before do
        # Force created item to have the same uid that appears in the csv fixture we're working with
        allow_any_instance_of(DigitalObject::Item).to receive(:mint_uid).and_return('2f4e2917-26f5-4d8f-968c-a4015b10e50f')
        # Create item that one of the csv rows will update
        FactoryBot.create(:item)
        described_class.process_csv_file_if_present(batch_import)
        batch_import.reload
      end

      let(:doi_records_by_row) do
        hsh = {}
        row_counter = 2
        DigitalObjectImport.count.times do
          hsh[row_counter] = DigitalObjectImport.find_by(index: row_counter)
          row_counter += 1
        end
        hsh
      end

      context "successful run" do
        it "does not result in a cancellation with setup errors on the BatchImport" do
          expect(batch_import.setup_errors).to be_blank
          expect(batch_import.cancelled).to eq(false)
        end

        it "assigns digital_object_data to all of the DigitalObjectImports" do
          doi_records_by_row.values.map(&:digital_object_data).each do |dod|
            expect(dod).to be_present
          end
        end

        it "sets up the expected DigitalObjectImports, all with status 'pending'" do
          expect(DigitalObjectImport.count).to eq(5)
          expect(DigitalObjectImport.all.pluck(:status).uniq).to eq(['pending'])
        end

        context "sets up the expected ImportPrerequisites" do
          it "and the total number is expected" do
            expect(ImportPrerequisite.count).to eq(4)
          end

          it "and the batch_import refernece is correct" do
            expect(ImportPrerequisite.all.map(&:batch_import).uniq).to eq([batch_import])
          end

          context "and the prerequisite dependencies are correct" do
            {
              3 => [2], # row 3 depends on row 2
              4 => [3], # row 4 depends on row 3
              5 => [4, 6] # row 5 depends on rows 4 and 6
            }.each do |row_number, prerequisite_row_numbers|
              prerequisite_row_numbers.each do |prerequisite_row_number|
                it "and row #{row_number} is set up as depending on prerequisite row #{prerequisite_row_number}" do
                  expect(
                    ImportPrerequisite.exists?(digital_object_import: doi_records_by_row[row_number], prerequisite_digital_object_import: doi_records_by_row[prerequisite_row_number])
                  ).to eq(true)
                end
              end
            end
          end
        end
      end
    end
  end

  context '.handle_job_error' do
    before do
      allow(Rails.logger).to receive(:error)
      allow(batch_import).to receive(:save!).and_call_original

      begin
        raise StandardError, "It's the most standard of errors!"
      rescue StandardError => e
        described_class.handle_job_error(batch_import, e)
      end
    end

    it "marks the batch_import as cancelled and saves the cancelled state" do
      expect(batch_import.cancelled).to eq(true)
      expect(batch_import).to have_received(:save!)
    end

    it "stores the exception's message in batch_import.setup_errors" do
      expect(batch_import.setup_errors.first).to include("It's the most standard of errors!")
    end

    it "logs the error to the rails error log" do
      expect(Rails.logger).to have_received(:error)
    end
  end

  context '.create_pending_digital_object_import' do
    let(:digital_object_data_hash) do
      {
        'uid' => '2f4e2917-26f5-4d8f-968c-a4015b10e50f',
        'identifiers' => 'item1'
      }
    end
    let(:csv_row_number) { 10 }
    let(:created_pending_digital_object_import) do
      described_class.create_pending_digital_object_import!(
        batch_import,
        digital_object_data_hash,
        csv_row_number
      )
    end
    it 'creates a persisted digital object import' do
      expect(created_pending_digital_object_import).to be_a(DigitalObjectImport)
      expect(created_pending_digital_object_import).to be_persisted
    end

    it "sets the created DigitalObjectImport's status to 'pending'" do
      expect(created_pending_digital_object_import.status).to eq('pending')
    end

    it 'stores the given csv row index in the record' do
      expect(created_pending_digital_object_import.index).to be_json_eql(csv_row_number)
    end

    it 'stores the given json hash as json in the record' do
      expect(created_pending_digital_object_import.digital_object_data).to be_json_eql(JSON.generate(digital_object_data_hash))
    end
  end
end
