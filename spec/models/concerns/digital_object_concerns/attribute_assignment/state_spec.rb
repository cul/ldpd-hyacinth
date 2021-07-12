# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DigitalObjectConcerns::AttributeAssignment::State do
  let(:digital_object) { FactoryBot.build(:digital_object_test_subclass) }

  context "#assign_state" do
    it "successfully sets the state" do
      digital_object.assign_state(
        'state' => 'deleted'
      )

      expect(digital_object.state).to eq('deleted')
    end
  end
end
