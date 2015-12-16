require 'rails_helper'

RSpec.describe DigitalObject::Base, :type => :model do

  describe "#initialize" do
    it "has a default dynamic_field_data value of {}" do
      @digital_object = DigitalObject::Item.new()
      expect(@digital_object.dynamic_field_data).to eq({})
    end
  end
  
  describe "#set_digital_object_data" do
    let(:sample_item_digital_object_data) {
      dod = JSON.parse( fixture('sample_digital_object_data/new_item.json').read )
      dod['identifiers'] = ['item.' + SecureRandom.uuid] # random identifer to avoid collisions
      dod
    }
    let(:sample_group_digital_object_data) {
      dod = JSON.parse( fixture('sample_digital_object_data/new_group.json').read )
      dod['identifiers'] = ['group.' + SecureRandom.uuid] # random identifer to avoid collisions
      dod
    }
    
    it "works for an Item that does not have a parent object" do
      @digital_object = DigitalObjectType.get_model_for_string_key(sample_item_digital_object_data['digital_object_type']['string_key']).new()
      @digital_object.set_digital_object_data(sample_item_digital_object_data, false)
      
      expect(@digital_object).to be_instance_of(DigitalObject::Item)
      expect(@digital_object.identifiers).to eq(sample_item_digital_object_data['identifiers'])
      expect(@digital_object.project.string_key).to eq('test')
      expect(@digital_object.publish_targets.map{|publish_target| publish_target.string_key}.sort).to eq(['test_publish_target_1', 'test_publish_target_2'])
      expect(@digital_object.dynamic_field_data).to eq(sample_item_digital_object_data['dynamic_field_data'])
      
      expect(@digital_object.created_by).to be_nil # Because we didn't set created_by
      expect(@digital_object.updated_by).to be_nil # Because we didn't set modified_by
    end
    
    it "works for an Item that references a parent Group" do
      # Create parent Group
      new_group = DigitalObjectType.get_model_for_string_key(sample_group_digital_object_data['digital_object_type']['string_key']).new()
      new_group.set_digital_object_data(sample_group_digital_object_data, false)
      new_group.save
      
      parent_group_pid = new_group.pid
      parent_group_identifier = new_group.identifiers.select{|identifier| identifier != parent_group_pid}.first
      
      # Set parent identifier for new item data
      sample_item_digital_object_data['parent_digital_objects'] = [
        {
          'identifier' => parent_group_identifier
        }
      ]
      
      # Create child Item that references parent Group
      new_item_with_parent_group = DigitalObjectType.get_model_for_string_key(sample_item_digital_object_data['digital_object_type']['string_key']).new()
      new_item_with_parent_group.set_digital_object_data(sample_item_digital_object_data, false)
      
      expect(new_item_with_parent_group).to be_instance_of(DigitalObject::Item)
      expect(new_item_with_parent_group.identifiers).to eq(sample_item_digital_object_data['identifiers'])
      expect(new_item_with_parent_group.parent_digital_object_pids).to eq([parent_group_pid])
      expect(new_item_with_parent_group.project.string_key).to eq('test')
      expect(new_item_with_parent_group.publish_targets.map{|publish_target| publish_target.string_key}.sort).to eq(['test_publish_target_1', 'test_publish_target_2'])
      expect(new_item_with_parent_group.dynamic_field_data).to eq(sample_item_digital_object_data['dynamic_field_data'])
      
      expect(new_item_with_parent_group.created_by).to be_nil # Because we didn't set created_by
      expect(new_item_with_parent_group.updated_by).to be_nil # Because we didn't set modified_by
    end
    
    it "raises an exception for an Item that references a parent identifier that doesn't exist" do
      # Set parent identifier for new item data
      sample_item_digital_object_data['parent_digital_objects'] = [
        {
          'identifier' => 'this is an identifier that definitely does not exist --- ' + SecureRandom.uuid
        }
      ]
      
      # Create child Item that references non-existant parent Group
      new_item_with_parent_group = DigitalObjectType.get_model_for_string_key(sample_item_digital_object_data['digital_object_type']['string_key']).new()
      expect {
        new_item_with_parent_group.set_digital_object_data(sample_item_digital_object_data, false)
      }.to raise_error(Hyacinth::Exceptions::ParentDigitalObjectNotFoundError)
    end
    
  end

end
