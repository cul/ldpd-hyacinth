require 'rails_helper'

RSpec.describe DigitalObject::PublishTarget, :type => :model, focus: true do
  let(:sample_publish_target_digital_object_data) {
    JSON.parse( fixture('sample_digital_object_data/new_publish_target.json').read )
  }
  let(:sample_item_digital_object_data) {
    JSON.parse( fixture('sample_digital_object_data/new_item.json').read )
  }

  let(:publish_target) do
    publish_target = DigitalObjectType.get_model_for_string_key(
      sample_publish_target_digital_object_data['digital_object_type']['string_key']
    ).new
    publish_target.set_digital_object_data(sample_publish_target_digital_object_data, false)
    publish_target
  end

  # NOTE: This is a placeholder file for future PublishTarget-specific tests
end
