require 'rails_helper'
require 'cancan/matchers'

RSpec.describe Ability, type: :model do
  describe 'when user is nil' do
    let(:user) { nil }

    subject { described_class.new(user) }

    it { is_expected.not_to be_able_to(:manage, Group) }
    it { is_expected.not_to be_able_to(:show, Group) }
  end

  describe 'when user is part of administrator group' do
    let(:group) { Group.create(string_key: 'administrator', is_admin: true) }
    let(:user) { FactoryBot.create(:user, groups: [group]) }

    subject { described_class.new(user) }

    it { is_expected.to be_able_to(:manage, :all) }
    it { is_expected.to be_able_to(:manage, Group) }
    it { is_expected.to be_able_to(:manage, DigitalObject) }
    it { is_expected.to be_able_to(:edit, Project) }
  end

  describe 'when user is part of group manager group' do
    let(:group) do
      Group.create!(
        string_key: 'group_managers',
        permissions: [Permission.create(action: Permission::MANAGE_GROUPS)]
      )
    end
    let(:user) { FactoryBot.create(:user, groups: [group]) }

    subject { described_class.new(user) }

    it { is_expected.not_to be_able_to(:manage, :all) }
    it { is_expected.to be_able_to(:show, Group) }
    it { is_expected.to be_able_to(:edit, Group) }
    it { is_expected.to be_able_to(:manage, Group) }
  end

  describe 'when user is part of user manager group' do
    let(:group) do
      Group.create!(
        string_key: 'user_managers',
        permissions: [Permission.create(action: Permission::MANAGE_USERS)]
      )
    end
    let(:user) { FactoryBot.create(:user, groups: [group]) }

    subject { described_class.new(user) }

    it { is_expected.not_to be_able_to(:manage, :all) }
    it { is_expected.to be_able_to(:manage, User) }
    it { is_expected.to be_able_to(:edit, User) }
    it { is_expected.to be_able_to(:show, User) }
    it { is_expected.to be_able_to(:update, User) }
  end

  describe 'when user has multiple system wide permissions' do
    let(:group) do
      Group.create!(
        string_key: 'user_and_group_managers',
        permissions: [
          Permission.create(action: Permission::MANAGE_USERS),
          Permission.create(action: Permission::MANAGE_GROUPS)
        ]
      )
    end
    let(:user) { FactoryBot.create(:user, groups: [group]) }

    subject { described_class.new(user) }

    it { is_expected.not_to be_able_to(:manage, :all) }
    it { is_expected.to be_able_to(:manage, User) }
    it { is_expected.to be_able_to(:edit, User) }
    it { is_expected.to be_able_to(:show, User) }
    it { is_expected.to be_able_to(:update, User) }
    it { is_expected.to be_able_to(:show, Group) }
    it { is_expected.to be_able_to(:edit, Group) }
    it { is_expected.to be_able_to(:manage, Group) }
  end

  describe 'when user is logged in' do
    let(:user) { FactoryBot.create(:user) }

    subject { described_class.new(user) }

    it { is_expected.to be_able_to(:index, Group) }
    it { is_expected.to be_able_to(:show, Group) }
    it { is_expected.to be_able_to(:read, Group) }
    it { is_expected.to be_able_to(:read, user) }
    it { is_expected.to be_able_to(:edit, user) }
    it { is_expected.to be_able_to(:update, user) }
  end
end
