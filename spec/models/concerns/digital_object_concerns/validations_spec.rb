# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DigitalObjectConcerns::Validations, type: :model do
  let(:item_invalid_uid) { FactoryBot.create(:item, uid: 'FFF') }
  let(:item_uid_caps) { FactoryBot.create(:item, uid: '2F4e2917-26f5-4d8f-968c-a4015b10e50f') }
  let(:item_valid) { FactoryBot.create(:item, uid: '2f4e2917-26f5-4d8f-968c-a4015b10e50f') }

  context "when a uid is provided on digital object create" do
    it "rejects an invalid uid" do
      expect { item_invalid_uid }.to raise_error ActiveRecord::RecordInvalid, 'Validation failed: Uid is invalid'
    end
    it "rejects a valid uid with uppercase letters" do
      expect { item_uid_caps }.to raise_error ActiveRecord::RecordInvalid, 'Validation failed: Uid is invalid'
    end
    it "accepts a valid uid" do
      expect(item_valid).to be_valid
    end
  end
end
