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
    it { is_expected.to be_able_to(:read, User) }
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
    it { is_expected.to be_able_to(:read, User) }
    it { is_expected.to be_able_to(:update, User) }
    it { is_expected.to be_able_to(:show, :vocabulary) }
    it { is_expected.to be_able_to(:update, :vocabulary) }
    it { is_expected.to be_able_to(:manage, :vocabulary) }
  end

  describe 'when user is logged in' do
    let(:user) { FactoryBot.create(:user) }

    subject { described_class.new(user) }

    it { is_expected.to be_able_to(:read, user) }
    it { is_expected.to be_able_to(:update, user) }

    it { is_expected.not_to be_able_to(:manage, User) }
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

  describe 'for digital object permissions' do
    let(:authorized_object) { FactoryBot.build(:digital_object_test_subclass, :with_sample_data, :with_lincoln_project) }
    let(:unauthorized_object) { FactoryBot.build(:digital_object_test_subclass, :with_sample_data, :with_minken_project) }
    let(:mixed_object) do
      obj = FactoryBot.build(:digital_object_test_subclass, :with_sample_data)
      obj.projects.merge authorized_object.projects
      obj.projects.merge unauthorized_object.projects
      obj
    end
    let(:authorized_project) { authorized_object.projects.to_a[0] }
    let(:unauthorized_project) { unauthorized_object.projects.to_a[0] }

    subject { described_class.new(user) }
    context 'when a user has the ability to update_objects for a project' do
      let(:user) do
        FactoryBot.create(
          :user, permissions: [
            Permission.create(action: :update_objects, subject: Project.to_s, subject_id: authorized_project.id)
          ]
        )
      end

      it { is_expected.to be_able_to(:update, authorized_object) }
      it { is_expected.to be_able_to(:update_objects, authorized_project) }
      it { is_expected.not_to be_able_to(:update_objects, unauthorized_project) }
      it { is_expected.to be_able_to(:update, mixed_object) }
      it { is_expected.not_to be_able_to(:update, unauthorized_object) }
      it { is_expected.not_to be_able_to(:destroy, authorized_object) }
      it { is_expected.not_to be_able_to(:publish, authorized_object) }
    end
    context 'when a user has the ability to delete_objects for a project' do
      let(:user) do
        FactoryBot.create(
          :user, permissions: [
            Permission.create(action: :delete_objects, subject: Project.to_s, subject_id: authorized_project.id)
          ]
        )
      end

      it { is_expected.to be_able_to(:destroy, authorized_object) }
      it { is_expected.to be_able_to(:delete_objects, authorized_project) }
      it { is_expected.not_to be_able_to(:delete_objects, unauthorized_project) }
      it { is_expected.to be_able_to(:destroy, mixed_object) }
      it { is_expected.not_to be_able_to(:destroy, unauthorized_object) }
      it { is_expected.not_to be_able_to(:update, authorized_object) }
      it { is_expected.not_to be_able_to(:publish, authorized_object) }
    end
    context 'when a user has the ability to publish_objects for a project' do
      let(:user) do
        FactoryBot.create(
          :user, permissions: [
            Permission.create(action: :publish_objects, subject: Project.to_s, subject_id: authorized_project.id)
          ]
        )
      end

      it { is_expected.to be_able_to(:publish, authorized_object) }
      it { is_expected.to be_able_to(:publish_objects, authorized_project) }
      it { is_expected.not_to be_able_to(:publish_objects, unauthorized_project) }
      it { is_expected.to be_able_to(:publish, mixed_object) }
      it { is_expected.not_to be_able_to(:publish, unauthorized_object) }
      it { is_expected.not_to be_able_to(:update, authorized_object) }
      it { is_expected.not_to be_able_to(:destroy, authorized_object) }
    end
    context 'when a user has the ability to create_objects for a project' do
      let(:user) do
        FactoryBot.create(
          :user, permissions: [
            Permission.create(action: :create_objects, subject: Project.to_s, subject_id: authorized_project.id)
          ]
        )
      end

      it { is_expected.to be_able_to(:create_objects, authorized_project) }
      it { is_expected.not_to be_able_to(:create_objects, unauthorized_project) }
    end
  end
end
