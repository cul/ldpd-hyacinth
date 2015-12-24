require 'rails_helper'

RSpec.describe ProcessDigitalObjectImportJob, :type => :job do

  before(:context) do

    @test_pid_generator = PidGenerator.create!(id: 2015, namespace: 'spectest')
    # create project to match project used in fixture
    @test_project = Project.create!(id: 2015, string_key: 'the_project', display_label: 'projectname.001.1', pid_generator: @test_pid_generator)
    @test_user = User.find_by_first_name('Test')
    @test_import_job = ImportJob.create!(id: 2015, name: 'Test Import Job', user: @test_user)
    @test_digital_object_import = DigitalObjectImport.create!(id: 2015, import_job: @test_import_job)
    @digital_object_data_as_ruby_struct = JSON.parse( fixture('lib/hyacinth/utils/csv_import_export/csv_to_json/new_asset_example.json').read ) 

  end

  after(:context) do

    @test_digital_object_import.destroy
    @test_import_job.destroy
    @test_project.destroy
    @test_pid_generator.destroy

      
  end

  context "#perform" do

    current_resque_inline_value = Resque.inline

    Resque.inline = true
    max_requeues = ProcessDigitalObjectImportJob::MAX_REQUEUES

    # doi is shorthand for DigitalObjectImport
    it "requeue_count equal to #{max_requeues + 1} for doi with nonexistent parent" do

      local_test_digital_object_import = @test_digital_object_import
      local_test_digital_object_import.digital_object_data = 
        ActiveSupport::JSON.encode @digital_object_data_as_ruby_struct
      local_test_digital_object_import.save!

      ProcessDigitalObjectImportJob::perform local_test_digital_object_import.id
      local_test_digital_object_import.reload
      Hyacinth::Utils::Logger.logger.debug "****** #{self.class.name} #{local_test_digital_object_import.requeue_count}"

      expect(local_test_digital_object_import.requeue_count).to eq(max_requeues+1)

    end

  end

end
