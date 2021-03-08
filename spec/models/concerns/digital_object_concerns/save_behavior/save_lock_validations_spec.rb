# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DigitalObjectConcerns::SaveBehavior::SaveLockValidations do
  describe 'saving a digital object when the optimistic lock token in the serialized version has been changed by a same-object save by a different process' do
    let(:item) { FactoryBot.create(:item) }
    before do
      DigitalObject::Base.find(item.uid).save # changes the optimistic lock token in the db
    end
    it 'fails with the expected error' do
      expect(item.save).to eq(false)
      expect(item.errors.include?(:optimistic_lock_token)).to eq(true)
    end
  end
end
