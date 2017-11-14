require 'rails_helper'

RSpec.describe ProcessDigitalObjectImportJob, :type => :job do

  let (:klass) { ProcessDigitalObjectImportJob }

  describe ".is_existing_object" do
    it "returns true if digital object data contains a pid field for an existing object" do
      existing_pid = 'it:exists'
      nonexisting_pid = 'it:doesnoteist'
      allow(DigitalObject::Base).to receive(:'exists?').with(existing_pid).and_return(true)
      allow(DigitalObject::Base).to receive(:'exists?').with(nonexisting_pid).and_return(false)
      expect(klass.is_existing_object({'pid' => existing_pid})).to eq(true)
      expect(klass.is_existing_object({'pid' => nonexisting_pid})).to eq(false)
      expect(klass.is_existing_object({})).to eq(false)
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

  end

  # before(:context) do
  #
  #   @test_pid_generator = PidGenerator.create!(id: 2015, namespace: 'spectest')
  #   # create project to match project used in fixture
  #   @test_project = Project.create!(id: 2015, string_key: 'the_project', display_label: 'projectname.001.1', pid_generator: @test_pid_generator)
  #   @test_user = User.find_by_first_name('Test')
  #   @test_import_job = ImportJob.create!(id: 2015, name: 'Test Import Job', user: @test_user)
  #   @test_digital_object_import = DigitalObjectImport.create!(id: 2015, import_job: @test_import_job)
  #   @digital_object_data_as_ruby_struct = JSON.parse( fixture('lib/hyacinth/utils/csv_import_export/csv_to_json/new_asset_example.json').read )
  #
  # end
  #
  # after(:context) do
  #
  #   @test_digital_object_import.destroy
  #   @test_import_job.destroy
  #   @test_project.destroy
  #   @test_pid_generator.destroy
  #
  #
  # end
  #
  # context "#perform" do
  #
  #   current_resque_inline_value = Resque.inline
  #
  #   Resque.inline = true
  #   max_requeues = ProcessDigitalObjectImportJob::MAX_REQUEUES
  #
  #   it "requeue_count equal to #{max_requeues + 1} for DigitalObjectImport with nonexistent parent" do
  #
  #     local_test_digital_object_import = @test_digital_object_import
  #     local_test_digital_object_import.digital_object_data =
  #       ActiveSupport::JSON.encode @digital_object_data_as_ruby_struct
  #     local_test_digital_object_import.save!
  #
  #     ProcessDigitalObjectImportJob::perform local_test_digital_object_import.id
  #     local_test_digital_object_import.reload
  #     Hyacinth::Utils::Logger.logger.debug "****** #{self.class.name} #{local_test_digital_object_import.requeue_count}"
  #
  #     expect(local_test_digital_object_import.requeue_count).to eq(max_requeues+1)
  #
  #   end
  #
  # end

end
