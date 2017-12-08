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

  end

end
