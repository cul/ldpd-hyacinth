require 'rails_helper'
require 'cancan/matchers'

RSpec.describe Ability, type: :model do
  describe 'when user is nil' do
    let(:user) { nil }

    subject { described_class.new(user) }

    it { is_expected.not_to be_able_to(:manage, User) }
    it { is_expected.not_to be_able_to(:show, User) }
  end

  describe 'when user is administrator' do
    let(:user) { FactoryBot.create(:user, is_admin: true) }

    subject { described_class.new(user) }

    it { is_expected.to be_able_to(:manage, :all) }
    it { is_expected.to be_able_to(:manage, :vocabulary) }
    it { is_expected.to be_able_to(:manage, DigitalObject) }
    it { is_expected.to be_able_to(:update, Project) }
    it { is_expected.to be_able_to(:update, PublishTarget) }
  end

  describe 'when user is user manager' do
    let(:user) do
      FactoryBot.create(
        :user, permissions: [Permission.create(action: Permission::MANAGE_USERS)]
      )
    end

    subject { described_class.new(user) }

    it { is_expected.not_to be_able_to(:manage, :all) }
    it { is_expected.to be_able_to(:manage, User) }
    it { is_expected.to be_able_to(:index, User) }
    it { is_expected.to be_able_to(:show, User) }
    it { is_expected.to be_able_to(:update, User) }
  end

  describe 'when user has multiple system wide permissions' do
    let(:user) do
      FactoryBot.create(
        :user, permissions: [
          Permission.create(action: Permission::MANAGE_USERS),
          Permission.create(action: Permission::MANAGE_VOCABULARIES)
        ]
      )
    end

    subject { described_class.new(user) }

    it { is_expected.not_to be_able_to(:manage, :all) }
    it { is_expected.to be_able_to(:manage, User) }
    it { is_expected.to be_able_to(:show, User) }
    it { is_expected.to be_able_to(:update, User) }
    it { is_expected.to be_able_to(:show, :vocabulary) }
    it { is_expected.to be_able_to(:update, :vocabulary) }
    it { is_expected.to be_able_to(:manage, :vocabulary) }
  end

  describe 'when user is logged in' do
    let(:user) { FactoryBot.create(:user) }

    subject { described_class.new(user) }

    it { is_expected.to be_able_to(:show, user) }
    it { is_expected.to be_able_to(:update, user) }

    it { is_expected.not_to be_able_to(:index, User) }
  end

  describe 'when user has the ability to read all digital objects' do
    let(:user) do
      FactoryBot.create(
        :user, permissions: [
          Permission.create(action: Permission::READ_ALL_DIGITAL_OBJECTS)
        ]
      )
    end

    subject { described_class.new(user) }

    it { is_expected.to be_able_to(:show, PublishTarget) }
    it { is_expected.to be_able_to(:show, FactoryBot.create(:publish_target)) }
  end

  describe 'when a user has the ability to read_objects for a project' do
    let(:project) { FactoryBot.create(:project) }
    let(:user) do
      FactoryBot.create(
        :user, permissions: [
          Permission.create(action: :read_objects, subject: Project.to_s, subject_id: project.id)
        ]
      )
    end

    subject { described_class.new(user) }

    it { is_expected.to be_able_to(:show, FactoryBot.create(:publish_target, project: project)) }
    it { is_expected.to be_able_to(:show, project) }
    it { is_expected.to be_able_to(:show, FactoryBot.create(:field_set, project: project)) }

    it { is_expected.not_to be_able_to(:update, FactoryBot.create(:field_set, project: project)) }
    it { is_expected.not_to be_able_to(:update, FactoryBot.create(:publish_target, project: project)) }
  end
end
