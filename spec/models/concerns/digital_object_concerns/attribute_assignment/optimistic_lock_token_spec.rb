# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DigitalObjectConcerns::AttributeAssignment::OptimisticLockToken do
  let(:digital_object) { FactoryBot.build(:digital_object_test_subclass) }
  let(:new_optimistic_lock_token_value) { 'brandnewtoken' }
  context "#assign_optimistic_lock_token" do
    it "successfully sets the assign_optimistic_lock_token" do
      digital_object.assign_optimistic_lock_token(
        'optimistic_lock_token' => new_optimistic_lock_token_value
      )

      expect(digital_object.optimistic_lock_token).to eq(new_optimistic_lock_token_value)
    end
  end
end
