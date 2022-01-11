# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DigitalObjectConcerns::Validations, type: :model do
  include_context 'with stubbed search adapters'

  let(:valid_uid) { '2f4e2917-26f5-4d8f-968c-a4015b10e50f' }
  let(:invalid_uid) { 'FFF' }
  context "when a uid is provided on digital object create" do
    it "rejects an invalid uid" do
      expect { FactoryBot.create(:item, uid: invalid_uid) }.to raise_error ActiveRecord::RecordInvalid, 'Validation failed: Uid is invalid'
    end
    it "rejects a capitalized version of a valid uid" do
      expect { FactoryBot.create(:item, uid: valid_uid.upcase) }.to raise_error ActiveRecord::RecordInvalid, 'Validation failed: Uid is invalid'
    end
    it "accepts a valid uid" do
      FactoryBot.create(:item, uid: valid_uid)
    end
  end
end
