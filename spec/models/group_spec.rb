require 'rails_helper'

RSpec.describe Group, type: :model do
  describe '#new' do
    let(:group) { FactoryBot.build(:group) }

    it 'creates a new group' do
      group.save
      expect(group).to be_a Group
      expect(group.string_key).to eq 'developers'
    end

    it 'requires a string_key' do
      expect(FactoryBot.build(:group, string_key: nil).save).to be false
    end

    it 'require string_key to be unique' do
      FactoryBot.create(:group)
      expect(group.save).to be false
    end

    it 'requires a string_key with alphanumeric characters and underscores (does not start with number)' do
      expect(FactoryBot.build(:group, string_key: '1test').save).to be false
    end
  end

  describe '#user' do
    let(:group) { FactoryBot.create(:group) }
    let(:user)  { FactoryBot.create(:user) }
    let(:user_2) { FactoryBot.create(:user, email: 'jane_doe_2@example.com') }

    it 'contains a user' do
      expect(group.users.count).to be 0
      group.users << user
      expect(group.save).to be true
      expect(group.users.count).to be 1
      expect(user.groups).to include group
    end

    it 'contains multiple users' do
      expect(group.users.count).to be 0
      group.users = [user, user_2]
      expect(group.save).to be true
      expect(group.users.count).to be 2
      expect(user.groups).to include group
    end
  end
end
