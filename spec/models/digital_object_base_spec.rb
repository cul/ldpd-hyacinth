require 'rails_helper'

RSpec.describe DigitalObject::Base, :type => :model do

  describe "#initialize" do
    it "has a default dynamic_field_data value of {}" do
      @digital_object = DigitalObject::Item.new()
      expect(@digital_object.dynamic_field_data).to eq({})
    end
  end
  
  describe "#update" do
    
    let(:sample_item_digital_object_data) { JSON.parse( fixture('sample_digital_object_data/new_item.json').read ) }
    
    it "sets the correct fields" do
      @digital_object = DigitalObjectType.get_model_for_string_key(sample_item_digital_object_data['digital_object_type']['string_key']).new()
      @digital_object.set_digital_object_data(sample_item_digital_object_data, false)
      
      expect(@digital_object).to be_instance_of(DigitalObject::Item)
      expect(@digital_object.identifiers).to eq(["identifier.001", "identifier.002"])
      expect(@digital_object.project.string_key).to eq('test')
      expect(@digital_object.publish_targets.map{|publish_target| publish_target.string_key}.sort).to eq(['test_publish_target_1', 'test_publish_target_2'])
      expect(@digital_object.dynamic_field_data).to eq(sample_item_digital_object_data['dynamic_field_data'])
      
      expect(@digital_object.created_by).to be_nil # Because we didn't set created_by
      expect(@digital_object.updated_by).to be_nil # Because we didn't set modified_by
    end
  end

end
