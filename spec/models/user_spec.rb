require 'rails_helper'

RSpec.describe User, type: :model do
  describe '#new' do
    let(:user) { FactoryBot.build(:user) }

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
end
