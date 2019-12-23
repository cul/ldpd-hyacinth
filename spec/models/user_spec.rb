# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { FactoryBot.build(:user) }

  describe '#new' do
    it 'set uid before saving new record' do
      expect(user.uid).to be_blank
      user.save
      expect(user.uid).not_to be_blank
    end

    it 'does not allow for uid to be changed' do
      user.save
      user.uid = 'new uid'
      expect(user.save).to be false
    end
  end

  describe "#full_name" do
    context "with no middle name" do
      it "generates the expected output" do
        expect(user.full_name).to eq('Jane Doe')
      end
    end

    context "with middle name" do
      let(:user) { FactoryBot.build(:user, middle_name: 'Aloysius') }
      it "generates the expected output" do
        expect(user.full_name).to eq('Jane Aloysius Doe')
      end
    end
  end
end
