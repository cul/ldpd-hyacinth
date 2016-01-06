require 'rails_helper'

RSpec.describe DigitalObject::Base, :type => :model do

  describe "#initialize" do
    it "has a default dynamic_field_data value of {}" do
      digital_object = DigitalObject::Item.new()
      expect(digital_object.dynamic_field_data).to eq({})
    end
    
    it "sets dynamic field data in both the DEPRECATED_HYACINTH_DATASTREAM_NAME and HYACINTH_CORE_DATASTREAM_NAME datastreams" do
      digital_object = DigitalObject::Item.new()
      digital_object.update_dynamic_field_data({
        "title" => [
          {
            "title_sort_portion" => "What a great title"
          }
        ]
      })
      digital_object.projects = [Project.first]
      digital_object.save
      
      # After save, all three hyacinth datastreams (including the deprecated one) should exist
      deprecated_hyacinth_ds = digital_object.fedora_object.datastreams[DigitalObject::Fedora::DEPRECATED_HYACINTH_DATASTREAM_NAME]
      hyacinth_core_ds = digital_object.fedora_object.datastreams[DigitalObject::Fedora::HYACINTH_CORE_DATASTREAM_NAME]
      hyacinth_struct_ds = digital_object.fedora_object.datastreams[DigitalObject::Fedora::HYACINTH_STRUCT_DATASTREAM_NAME]
      expect(deprecated_hyacinth_ds).not_to be(nil)
      expect(hyacinth_core_ds).not_to be(nil)
      expect(hyacinth_struct_ds).not_to be(nil)
      
      # The deprecated hyacinth datastream should contain both dynamic field data and struct data
      expect(JSON.parse(deprecated_hyacinth_ds.content)).to eq({
        "dynamic_field_data" => {"title" => [{"title_sort_portion" => "What a great title"}]},
        "ordered_child_digital_object_pids" => []
      })
      # The core hyacinth datastream should contain only dynamic field data
      expect(JSON.parse(hyacinth_core_ds.content)).to eq({
        "dynamic_field_data" => {"title" => [{"title_sort_portion" => "What a great title"}]}
      })
      # The struct hyacinth datastream should contain only struct data
      expect(JSON.parse(hyacinth_struct_ds.content)).to eq([])
    end
    
  end

end