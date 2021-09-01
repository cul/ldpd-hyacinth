# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DigitalObjectImportProcessingJob, solr: true do
  let(:user) { FactoryBot.create(:user) }
  let(:batch_import) { FactoryBot.create(:batch_import, user: user) }
  let(:digital_object_import) { FactoryBot.create(:digital_object_import, batch_import: batch_import) }
  let(:digital_object_import_id) { digital_object_import.id }

  let(:second_digital_object_import) { FactoryBot.create(:digital_object_import, batch_import: batch_import, index: 2) }
  let(:third_digital_object_import) { FactoryBot.create(:digital_object_import, batch_import: batch_import, index: 3) }

  let(:created_digital_object) { DigitalObject.find_by_uid!(DigitalObject.first.uid) }

  context '.perform' do
    before do
      allow(described_class).to receive(:find_digital_object_import).and_return(digital_object_import)
      allow(described_class).to receive(:queue_applicable_import_prerequisites).and_call_original
      allow(described_class).to receive(:apply_recursive_failure!).and_call_original
      allow(digital_object_import).to receive(:in_progress!).and_call_original
      data_hash = JSON.parse(digital_object_import.digital_object_data)
      DynamicFieldsHelper.enable_dynamic_fields(data_hash["digital_object_type"], Project.find_by_string_key(data_hash["primary_project"]["string_key"]))
      described_class.perform(digital_object_import_id)
    end

    context 'successful run' do
      it 'marks the DigitalObjectImport as in_progress during processing' do
        expect(digital_object_import).to have_received(:in_progress!)
      end

      it 'results in a DigitalObjectImport status of success at the end of the job' do
        expect(digital_object_import.status).to eq('success')
      end

      it 'results in a DigitalObjectImport with no import_errors' do
        expect(digital_object_import.import_errors).to be_blank
      end

      context 'creates the expected digital object' do
        it "is of the expected type" do
          expect(created_digital_object).to be_a(DigitalObject::Item)
        end

        it "has the expected title data" do
          expect(created_digital_object.title).to eq('value' => { 'sort_portion' => 'The', 'non_sort_portion' => 'Cool Item' })
        end

        it "has the expected dyanamic field data" do
          expect(created_digital_object.descriptive_metadata).to eq(
            'abstract' => [{ 'value' => 'some abstract' }]
          )
        end

        it "is marked as created and updated by the expected user" do
          expect(created_digital_object.created_by).to eq(user)
          expect(created_digital_object.updated_by).to eq(user)
        end
      end

      it "queues associated import prerequisites" do
        expect(described_class).to have_received(:queue_applicable_import_prerequisites).with(digital_object_import)
      end
    end

    context 'successful run for an Asset with a resource' do
      let(:digital_object_import) { FactoryBot.create(:digital_object_import, :asset, batch_import: batch_import) }
      it "does not result in any import_errors" do
        expect(digital_object_import.import_errors).to be_blank
      end
      it "creates an asset" do
        expect(created_digital_object).to be_a(DigitalObject::Asset)
      end
    end

    context 'failed run' do
      let(:digital_object_import) do
        doi = FactoryBot.create(:digital_object_import, batch_import: batch_import)
        dod = JSON.parse(doi.digital_object_data)
        dod['state'] = 'ZZZ'
        doi.digital_object_data = JSON.generate(dod)
        doi
      end

      it 'results in a DigitalObjectImport status of creation_failure at the end of the job' do
        expect(digital_object_import.status).to eq('creation_failure')
      end

      it 'results in a DigitalObjectImport with import_errors' do
        expect(digital_object_import.import_errors).to be_present
      end

      it "includes digital object validation error messages in the import_errors array" do
        expect(digital_object_import.import_errors.length).to eq(1)
        expect(digital_object_import.import_errors.first).to start_with("'ZZZ' is not a valid state")
      end

      it "does NOT queue associated import prerequisites" do
        expect(described_class).not_to have_received(:queue_applicable_import_prerequisites).with(digital_object_import)
      end

      it "applies a recursive failure to the digital_object_import" do
        expect(described_class).to have_received(:apply_recursive_failure!).with(digital_object_import)
      end
    end
  end

  context '.queue_applicable_import_prerequisites' do
    before do
      FactoryBot.create(
        :import_prerequisite,
        prerequisite_digital_object_import: digital_object_import,
        digital_object_import: second_digital_object_import,
        batch_import: batch_import
      )
      FactoryBot.create(
        :import_prerequisite,
        prerequisite_digital_object_import: digital_object_import,
        digital_object_import: third_digital_object_import,
        batch_import: batch_import
      )

      allow(Resque).to receive(:enqueue).and_call_original
      described_class.queue_applicable_import_prerequisites(digital_object_import)
    end
    it "queues the expected ImportPrerequisites" do
      expect(Resque).to have_received(:enqueue).with(DigitalObjectImportProcessingJob, second_digital_object_import.id)
      expect(Resque).to have_received(:enqueue).with(DigitalObjectImportProcessingJob, third_digital_object_import.id)
    end
  end

  context '.digital_object_for_digital_object_data' do
    let(:digital_object) { FactoryBot.create(:item) }

    let(:existing_digital_object_data) do
      {
        'uid' => digital_object.uid
      }
    end

    let(:new_digital_object_data) do
      {
        'identifier' => 'this-identifier-does-not-exist-anywhere',
        'digital_object_type' => 'item'
      }
    end

    let(:unusable_digital_object_data) do
      {}
    end

    it 'finds an existing digital object when a uid is provided in the digital_object_data' do
      expect(
        described_class.digital_object_for_digital_object_data(existing_digital_object_data).new_record?
      ).to eq(false)
    end

    it 'instantiates a new digital object of the expected type when a uid is NOT provided in the digital_object_data' do
      obj = described_class.digital_object_for_digital_object_data(new_digital_object_data)
      expect(obj).to be_a(DigitalObject::Item)
      expect(obj.new_record?).to eq(true)
    end

    it 'raises an error if neither uid nor digital_object_type are keys in the digital_object_data' do
      expect {
        described_class.digital_object_for_digital_object_data(unusable_digital_object_data).new_record?
      }.to raise_error(ArgumentError)
    end
  end

  context '.apply_recursive_failure!' do
    before do
      FactoryBot.create(
        :import_prerequisite,
        prerequisite_digital_object_import: digital_object_import,
        digital_object_import: second_digital_object_import,
        batch_import: batch_import
      )
      FactoryBot.create(
        :import_prerequisite,
        prerequisite_digital_object_import: second_digital_object_import,
        digital_object_import: third_digital_object_import,
        batch_import: batch_import
      )
      described_class.apply_recursive_failure!(digital_object_import)
      second_digital_object_import.reload
      third_digital_object_import.reload
    end

    it "applies a failure status to the given digital_object_import, and recursively calls itself "\
      "for any other DigitalObjectImports the given import was a prerequiste for" do
      expect(digital_object_import.status).to eq('creation_failure')
      expect(second_digital_object_import.status).to eq('creation_failure')
      expect(third_digital_object_import.status).to eq('creation_failure')
    end

    context 'appropriate failure types' do
      let(:third_digital_object_import) do
        dobj_import = FactoryBot.create(:digital_object_import, batch_import: batch_import, index: 3)
        dobj_import.digital_object_data = { 'uid' => 'some-uid-value' }.to_json
        dobj_import.save
        dobj_import
      end

      it "marks an object creation failure as a creation_failure" do
        expect(digital_object_import.status).to eq('creation_failure')
      end

      it "marks an object update failure as an update_failure" do
        expect(third_digital_object_import.status).to eq('update_failure')
      end
    end
  end
end
