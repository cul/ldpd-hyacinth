require 'rails_helper'

RSpec.describe Group, type: :model do
  let(:group) { Group.create(string_key: 'developers') }
  let(:user)  do
    User.create(
      first_name: 'Test', last_name: 'User', email: 'test_user@example.com',
      password: 'terriblepassword', password_confirmation: 'terriblepassword'
    )
  end

  let(:user_2)  do
    User.create(
      first_name: 'Test', last_name: 'User2', email: 'test_user_2@example.com',
      password: 'terriblepassword', password_confirmation: 'terriblepassword'
    )
  end

  describe '#create' do
    it 'creates a new group' do
      expect(group).to be_a Group
      expect(group.string_key).to eq 'developers'
    end

    it 'requires a string_key' do
      pending
      expect(Group.new(string_key: '')).to be false
    end
  end

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
