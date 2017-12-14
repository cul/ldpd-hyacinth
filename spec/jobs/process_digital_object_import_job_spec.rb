require 'rails_helper'

RSpec.describe ProcessDigitalObjectImportJob, :type => :job do

  let (:klass) { ProcessDigitalObjectImportJob }

  describe ".existing_object?" do
    it "returns true if digital object data contains a pid field for an existing object" do
      existing_pid = 'it:exists'
      nonexisting_pid = 'it:doesnoteist'
      allow(DigitalObject::Base).to receive(:'exists?').with(existing_pid).and_return(true)
      allow(DigitalObject::Base).to receive(:'exists?').with(nonexisting_pid).and_return(false)
      expect(klass.existing_object?({'pid' => existing_pid})).to eq(true)
      expect(klass.existing_object?({'pid' => nonexisting_pid})).to eq(false)
      expect(klass.existing_object?({})).to eq(false)
    end
  end

  describe ".assign_data" do
    let(:digital_object) { DigitalObject::Item.new }
    let(:digital_object_data) { {} }
    let(:digital_object_import) { DigitalObjectImport.new }

    it "returns :success when everything works as expected and doesn't set any errors on passed DigitalObjectImport arg" do
      allow_any_instance_of(DigitalObject::Item).to receive(:set_digital_object_data).and_return({})
      expect(klass.assign_data(digital_object, digital_object_data, digital_object_import)).to eq(:success)
      expect(digital_object_import.digital_object_errors).to be_blank
    end

    it "returns :parent_not_found and sets digital_object_errors on passed DigitalObjectImport arg when DigitalObject::Base#set_digital_object_data raises Hyacinth::Exceptions::ParentDigitalObjectNotFoundError" do
      allow_any_instance_of(DigitalObject::Item).to receive(:set_digital_object_data).and_raise(Hyacinth::Exceptions::ParentDigitalObjectNotFoundError)
      expect(klass.assign_data(digital_object, digital_object_data, digital_object_import)).to eq(:parent_not_found)
      expect(digital_object_import.digital_object_errors).to be_present
    end

    it "returns :failure and sets digital_object_errors on passed DigitalObjectImport arg when DigitalObject::Base#set_digital_object_data raises any Exception other than Hyacinth::Exceptions::ParentDigitalObjectNotFoundError" do
      [Exception, Hyacinth::Exceptions::NotFoundError, Hyacinth::Exceptions::MalformedControlledTermFieldValue, UriService::Error].each do |exception_class|
        allow_any_instance_of(DigitalObject::Item).to receive(:set_digital_object_data).and_raise(exception_class)
        expect(klass.assign_data(digital_object, digital_object_data, digital_object_import)).to eq(:failure)
        expect(digital_object_import.digital_object_errors).to be_present
      end
    end
  end

  describe ".existing_object_for_update" do
    let(:pid) { 'abc:123' }
    let(:digital_object_data) { {'pid' => pid} }
    let(:user) {
      User.new(
        :email => 'abc@example.com',
        :password => 'password',
        :password_confirmation => 'password',
        :first_name => 'Abraham',
        :last_name => 'Lincoln',
        :is_admin => 'false'
      )
    }

    it "returns an existing object with given user assigned to updated_by field" do
      allow(DigitalObject::Base).to receive(:find).with(pid).and_return(DigitalObject::Item.new)
      obj = klass.existing_object_for_update(digital_object_data, user)
      expect(obj).to be_a(DigitalObject::Item)
      expect(obj.updated_by).to eq(user)
    end
  end

  describe ".new_object" do
    let(:user) {
      User.new(
        :email => 'abc@example.com',
        :password => 'password',
        :password_confirmation => 'password',
        :first_name => 'Abraham',
        :last_name => 'Lincoln',
        :is_admin => 'false'
      )
    }
    let(:digital_object_import) {
      DigitalObjectImport.new
    }

    context "valid digital object type" do
      let(:digital_object_type) { 'item' }

      it "returns a new object with expected created_by and updated_by values and correct type" do
        obj = klass.new_object(digital_object_type, user, digital_object_import)
        expect(obj).to be_a(DigitalObject::Item)
        expect(obj.created_by).to eq(user)
        expect(obj.updated_by).to eq(user)
        expect(digital_object_import.digital_object_errors).to be_blank
      end
    end

    context "valid digital object type" do
      let(:digital_object_type) { 'invalid_item_type' }
      it "passes an error to the digital_object_import.digital_object_errors array when an invalid digital object type is given" do
        klass.new_object(digital_object_type, user, digital_object_import)
        expect(digital_object_import.digital_object_errors.length).to eq(1)
        expect(digital_object_import.digital_object_errors[0]).to eq("Invalid DigitalObjectType string key: #{digital_object_type}")
      end
    end
  end

  describe ".handle_success_or_failure" do
    let(:digital_object_import) {
      DigitalObjectImport.new
    }
    let(:digital_object) {
      DigitalObject::Item.new
    }
    let(:do_solr_commit) { true }
    it "sets success status on digital_object_import when passed in status is :success and digital object save operation is successful" do
      allow_any_instance_of(DigitalObject::Item).to receive(:save).and_return(true)
      allow_any_instance_of(DigitalObjectImport).to receive(:save!).and_return(true)
      klass.handle_success_or_failure(:success, digital_object, digital_object_import, :success)
      expect(digital_object_import.status).to eq('success')
    end

    it "sets failure status on digital_object_import when passed in status is :failure, even if digital object save would have returned true" do
      allow_any_instance_of(DigitalObject::Item).to receive(:save).and_return(true)
      allow_any_instance_of(DigitalObjectImport).to receive(:save!).and_return(true)
      klass.handle_success_or_failure(:failure, digital_object, digital_object_import, :success)
      expect(digital_object_import.status).to eq('failure')
    end

    it "sets failure status on digital_object_import when passed in status is :success, but digital object save returns false" do
      allow_any_instance_of(DigitalObject::Item).to receive(:save).and_return(false)
      allow_any_instance_of(DigitalObjectImport).to receive(:save!).and_return(true)
      klass.handle_success_or_failure(:success, digital_object, digital_object_import, :success)
      expect(digital_object_import.status).to eq('failure')
    end
  end

  describe ".handle_remaining_prerequisite_case" do
    let(:digital_object_import_id) {
      12345
    }
    let(:digital_object_import) {
      DigitalObjectImport.new(id: digital_object_import_id)
    }
    context "clears errors on the digital_object_import and requeues when queue_long_jobs arg is set to true" do
      let(:queue_long_jobs) { true }
      it do
        allow_any_instance_of(DigitalObjectImport).to receive(:save!).and_return(true)
        expect(Hyacinth::Queue).to receive(:process_digital_object_import).with(digital_object_import_id)
        digital_object_import.digital_object_errors << 'An error'
        klass.handle_remaining_prerequisite_case(digital_object_import, queue_long_jobs)
        expect(digital_object_import.digital_object_errors).to be_blank
      end
    end

    context "marks digital_object_import as a failure when queue_long_jobs arg is set to false, preserves existing errors, and adds additional error message" do
      let(:queue_long_jobs) { false }
      it do
        error_message = 'An error'
        allow_any_instance_of(DigitalObjectImport).to receive(:save!).and_return(true)
        digital_object_import.digital_object_errors << error_message
        klass.handle_remaining_prerequisite_case(digital_object_import, queue_long_jobs)
        expect(digital_object_import.digital_object_errors).to include(error_message)
        expect(digital_object_import.digital_object_errors.length).to eq(2)
      end
    end
  end

  describe ".prerequisite_row_check" do
    let(:digital_object_import_1) {
      digital_object_import = DigitalObjectImport.new
      digital_object_import.csv_row_number = 1
      digital_object_import.prerequisite_csv_row_numbers = []
      digital_object_import.status = :pending
      digital_object_import
    }
    let(:digital_object_import_2) {
      digital_object_import = DigitalObjectImport.new
      digital_object_import.csv_row_number = 2
      digital_object_import.prerequisite_csv_row_numbers = [1]
      digital_object_import.status = :pending
      digital_object_import
    }
    let(:queue_long_jobs) { true }
    context "returns true if digital_object_import has no prerequisite rows" do
      let(:digital_object_import) { digital_object_import_1 }
      it do
        expect(klass.prerequisite_row_check(digital_object_import, queue_long_jobs)).to eq(true)
      end
    end
    context "returns true if digital_object_import has prerequisite rows that have already been successfully processed" do
      let(:digital_object_import) { digital_object_import_2 }
      let(:prerequisite_digital_object_imports) {
        digital_object_import_1.status = :success # Mark dependent job as successfully completed
        [digital_object_import_1]
      }
      it do
        allow(DigitalObjectImport).to receive(:where).and_return(prerequisite_digital_object_imports)
        expect(klass.prerequisite_row_check(digital_object_import, queue_long_jobs)).to eq(true)
      end
    end
    context "returns false if any of this digital_object_import's prerequisite rows are pending, and calls method handle_remaining_prerequisite_case with expected arguments" do
      let(:digital_object_import) { digital_object_import_2 }
      let(:prerequisite_digital_object_imports) {
        [digital_object_import_1]
      }
      it do
        allow(DigitalObjectImport).to receive(:where).and_return(prerequisite_digital_object_imports)
        expect(klass).to receive(:handle_remaining_prerequisite_case).with(digital_object_import, queue_long_jobs)
        expect(klass.prerequisite_row_check(digital_object_import, queue_long_jobs)).to eq(false)
      end
    end
    context "returns false if any of this digital_object_import's prerequisite rows have failed, and also adds an error to this digital_object_import that describes the failure" do
      let(:digital_object_import) { digital_object_import_2 }
      let(:prerequisite_digital_object_imports) {
        digital_object_import_1.status = :failure # Mark dependent job as a failure
        [digital_object_import_1]
      }
      it do
        allow(DigitalObjectImport).to receive(:where).and_return(prerequisite_digital_object_imports)
        allow_any_instance_of(DigitalObjectImport).to receive(:save!).and_return(true)
        expect(klass.prerequisite_row_check(digital_object_import, queue_long_jobs)).to eq(false)
        expect(digital_object_import.digital_object_errors.length).to eq(1)
        expect(digital_object_import.digital_object_errors[0]).to eq("Failed because prerequisite row 1 failed to import properly")
      end
    end
  end

  describe ".perform" do
    let(:digital_object_import_id) {
      allow(DigitalObjectImport).to receive(:find).with(12345).and_return(digital_object_import)
      12345
    }
    let(:user) {
      User.new(
        :email => 'abc@example.com',
        :password => 'password',
        :password_confirmation => 'password',
        :first_name => 'Abraham',
        :last_name => 'Lincoln',
        :is_admin => 'false'
      )
    }
    let(:import_job) {
      import_job = ImportJob.new
      import_job.user = user
      import_job
    }
    let(:digital_object_import) {
      digital_object_import = DigitalObjectImport.new
      digital_object_import.import_job = import_job
      digital_object_import.digital_object_data = {
        'digital_object_type' => {
          'string_key' => 'item'
        },
        'dynamic_field_data' => {
          'title' => [
            {
              'title_non_sort_portion' => 'The',
              'title_sort_portion' => 'Princess Bride'
            }
          ]
        }
      }.to_json
      digital_object_import
    }

    it "returns early when .prerequisite_row_check fails" do
      allow(klass).to receive(:prerequisite_row_check).and_return(false)
      expect(klass).not_to receive(:existing_object?)
      klass.perform(digital_object_import_id)
    end
    context "successful .prerequisite_row_check" do
      before {
        allow(klass).to receive(:prerequisite_row_check).and_return(true)
      }
      it "internally calls .existing_object_for_update when .existing_object? returns true" do
        allow(klass).to receive(:existing_object?).and_return(true)
        allow(klass).to receive(:handle_success_or_failure)
        expect(klass).to receive(:existing_object_for_update)
        klass.perform(digital_object_import_id)
      end
      it "internally calls .new_object when .existing_object? returns false" do
        allow(klass).to receive(:existing_object?).and_return(false)
        allow(klass).to receive(:handle_success_or_failure)
        expect(klass).to receive(:new_object)
        klass.perform(digital_object_import_id)
      end
      context "internally creates new digital object or retrieves existing digital object" do
        context "internally calls handle_success_or_failure if the result returned by .assign_data is not :parent_not_found" do
          it ":success" do
            allow(klass).to receive(:assign_data).and_return(:success)
            expect(klass).to receive(:handle_success_or_failure)
            klass.perform(digital_object_import_id)
          end
          it ":failure" do
            allow(klass).to receive(:assign_data).and_return(:failure)
            expect(klass).to receive(:handle_success_or_failure)
            klass.perform(digital_object_import_id)
          end
        end
        context "when receiving :parent_not_found from first internal call to .assign_data" do
          it "sleep when :parent_not_found is returned the first time, and then internally call handle_success_or_failure when :success is returned after the second .assign_data call (to simulate scenario when parent object was in the middle of concurrent processing, perhaps coming from a different csv import job)" do
            allow(klass).to receive(:assign_data).and_return(:parent_not_found, :success).twice
            expect(klass).to receive(:sleep)
            expect(klass).to receive(:handle_success_or_failure)
            klass.perform(digital_object_import_id)
          end
          it "sleep when :parent_not_found is returned the first time, and then again on second try of .assign_data, and sets failure status and an error message on the digital_object_import" do
            allow(klass).to receive(:assign_data).and_return(:parent_not_found).twice
            allow_any_instance_of(DigitalObjectImport).to receive(:save!).and_return(true)
            expect(klass).to receive(:sleep)
            klass.perform(digital_object_import_id)
            expect(digital_object_import.status).to eq('failure')
            expect(digital_object_import.digital_object_errors.length).to eq(1)
            expect(digital_object_import.digital_object_errors[0]).to eq("Failed because referenced parent object could not be found.")
          end
        end
      end
    end
  end
end
