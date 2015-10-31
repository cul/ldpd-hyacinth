require 'rails_helper'

RSpec.describe DigitalObjectImport, :type => :model do

  before(:context) do

    # @test_user = User.create!(id: 1966, name:'Test User')
    @test_user = User.find_by_first_name('Test')
    @test_import_job = ImportJob.create!(id: 1966, name: 'Test Import Job', user: @test_user)
    @test_digital_object_import = DigitalObjectImport.create!(id: 1966, import_job: @test_import_job)

  end

  after(:context) do

    @test_digital_object_import.destroy
    @test_import_job.destroy
    # @test_user.destroy

      
  end

  context "#new: " do

    it "name of belongs_to ImportJob matches name of ImportJob instance passed at creation" do
    
  
      local_import_job = @test_digital_object_import.import_job
      expect(local_import_job.name).to eq(@test_import_job.name)

    end

    it "the status of a newly created instance is pending" do

      expect(@test_digital_object_import.pending?).to eq(true)

    end
    
  end  

  context "after call to #success! :" do

    it "#success? returns true" do

      @test_digital_object_import.success!
      expect(@test_digital_object_import.success?).to eq(true)

    end

    it "#pending? returns false" do

      @test_digital_object_import.success!
      expect(@test_digital_object_import.pending?).to eq(false)

    end

    it "#failure? returns false" do

      @test_digital_object_import.success!
      expect(@test_digital_object_import.failure?).to eq(false)

    end

  end

  context "after call to #failure! :" do

    it "#success? returns false" do

      @test_digital_object_import.failure!
      expect(@test_digital_object_import.failure?).to eq(true)

    end

    it "#pending? returns false" do

      @test_digital_object_import.failure!
      expect(@test_digital_object_import.pending?).to eq(false)

    end

    it "#success? returns false" do

      @test_digital_object_import.failure!
      expect(@test_digital_object_import.success?).to eq(false)

    end

  end

  context "after call to #pending! :" do

    it "#pending? returns true" do

      @test_digital_object_import.pending!
      expect(@test_digital_object_import.pending?).to eq(true)

    end

    it "#success? returns false" do

      @test_digital_object_import.pending!
      expect(@test_digital_object_import.success?).to eq(false)

    end

    it "#failure? returns false" do

      @test_digital_object_import.pending!
      expect(@test_digital_object_import.failure?).to eq(false)

    end

  end

  context "attribute digital_object_errors :" do

    it "is correctly serialized upon save, and unserialized on retrieval" do

      test_array = ['This is the first error message', 'This is the second error message']
      @test_digital_object_import.digital_object_errors = test_array
      @test_digital_object_import.save!
      local_test_digital_object_import = DigitalObjectImport.find(1966)
      expect(local_test_digital_object_import.digital_object_errors).to eq(test_array)

    end

  end

end
