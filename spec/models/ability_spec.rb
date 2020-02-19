# frozen_string_literal: true

require 'rails_helper'
require 'cancan/matchers'

RSpec.describe Ability, type: :model do
  let(:base_rules) do
    [
      { actions: [:read, :update], conditions: { id: 1 }, subject: ["User"], inverted: false },
      { actions: [:read, :update], conditions: { uid: user.uid }, subject: ["User"], inverted: false },
      { actions: [:read, :create], conditions: {}, subject: ["Term"], inverted: false },
      { actions: [:read], conditions: {}, subject: ["Vocabulary"], inverted: false },
      { actions: [:read], conditions: {}, subject: ["DynamicFieldCategory"], inverted: false },
      { actions: [:read], conditions: { user_id: 1 }, subject: ["ExportJob"], inverted: false },
      { actions: [:destroy], conditions: { user_id: 1 }, subject: ["ExportJob"], inverted: false }
    ]
  end

  describe 'when user is nil' do
    subject { described_class.new(user) }

    let(:user) { nil }

    it { is_expected.not_to be_able_to(:manage, User) }
    it { is_expected.not_to be_able_to(:show, User) }
  end

  describe 'when user is administrator' do
    subject(:ability) { described_class.new(user) }

    let(:user) { FactoryBot.create(:user, is_admin: true) }

    it { is_expected.to be_able_to(:manage, :all) }
    it { is_expected.to be_able_to(:manage, Vocabulary) }
    it { is_expected.to be_able_to(:manage, DigitalObject) }
    it { is_expected.to be_able_to(:update, Project) }
    it { is_expected.to be_able_to(:update, PublishTarget) }

    it 'serializes correctly' do
      expect(ability.to_list).to match([{ actions: [:manage], conditions: {}, subject: [:all], inverted: false }])
    end
  end

  describe 'when user is user manager' do
    subject(:ability) { described_class.new(user) }

    let(:user) do
      FactoryBot.create(
        :user, permissions: [Permission.create(action: Permission::MANAGE_USERS)]
      )
    end

    it { is_expected.not_to be_able_to(:manage, :all) }
    it { is_expected.to be_able_to(:manage, User) }
    it { is_expected.to be_able_to(:read, User) }
    it { is_expected.to be_able_to(:update, User) }

    it 'serializes correctly' do
      expect(ability.to_list).to match_array(
        base_rules.concat([{ actions: [:manage], conditions: {}, subject: ['User'], inverted: false }])
      )
    end
  end

  describe 'when user has multiple system wide permissions' do
    subject(:ability) { described_class.new(user) }

    let(:user) do
      FactoryBot.create(
        :user, permissions: [
          Permission.create(action: Permission::MANAGE_USERS),
          Permission.create(action: Permission::MANAGE_VOCABULARIES)
        ]
      )
    end

    let(:additional_rules) do
      [
        { actions: [:manage], conditions: {}, subject: ["User"], inverted: false },
        { actions: [:manage], conditions: {}, subject: ["Vocabulary"], inverted: false },
        { actions: [:manage], conditions: {}, subject: ["Term"], inverted: false },
        { actions: [:manage], conditions: {}, subject: ["CustomField"], inverted: false }
      ]
    end

    it { is_expected.not_to be_able_to(:manage, :all) }
    it { is_expected.to be_able_to(:manage, User) }
    it { is_expected.to be_able_to(:read, User) }
    it { is_expected.to be_able_to(:update, User) }

    it { is_expected.to be_able_to(:show, Vocabulary) }
    it { is_expected.to be_able_to(:update, Vocabulary) }
    it { is_expected.to be_able_to(:manage, Vocabulary) }

    it 'serializes correctly' do
      expect(ability.to_list).to match_array(
        base_rules.concat(additional_rules)
      )
    end
  end

  describe 'when user is logged in' do
    subject(:ability) { described_class.new(user) }

    let(:user) { FactoryBot.create(:user) }

    it { is_expected.to be_able_to(:read, user) }
    it { is_expected.to be_able_to(:update, user) }

    it { is_expected.not_to be_able_to(:manage, User) }

    it 'serializes correctly' do
      expect(ability.to_list).to match(base_rules)
    end
  end

  describe 'when user has the ability to read all digital objects' do
    subject { described_class.new(user) }

    let(:user) do
      FactoryBot.create(
        :user, permissions: [
          Permission.create(action: Permission::READ_ALL_DIGITAL_OBJECTS)
        ]
      )
    end

    it { is_expected.to be_able_to(:read, Project) }
    it { is_expected.to be_able_to(:read, PublishTarget) }
    it { is_expected.to be_able_to(:read, FieldSet) }
    it { is_expected.not_to be_able_to(:update, Project) }
    it { is_expected.to be_able_to(:read, FactoryBot.create(:publish_target)) }
    it { is_expected.to be_able_to(:read, DigitalObject::Base) }
    it { is_expected.not_to be_able_to(:update, DigitalObject::Base) }
  end

  describe 'when user has the ability to manage all digital objects' do
    subject { described_class.new(user) }

    let(:user) do
      FactoryBot.create(
        :user, permissions: [
          Permission.create(action: Permission::MANAGE_ALL_DIGITAL_OBJECTS)
        ]
      )
    end

    it { is_expected.to be_able_to(:read, Project) }
    it { is_expected.to be_able_to(:read, PublishTarget) }
    it { is_expected.to be_able_to(:read, FieldSet) }
    it { is_expected.not_to be_able_to(:update, Project) }
    it { is_expected.to be_able_to(:publish_objects, Project) }
    it { is_expected.to be_able_to(:access_rights, Project) }
    it { is_expected.to be_able_to(:read, DigitalObject::Base) }
    it { is_expected.to be_able_to(:update, DigitalObject::Base) }
    it { is_expected.to be_able_to(:destroy, DigitalObject::Base) }
    it { is_expected.to be_able_to(:create, DigitalObject::Base) }
  end

  describe 'when a user has the ability to read_objects for a project' do
    subject(:ability) { described_class.new(user) }

    let(:project) { FactoryBot.create(:project) }
    let(:user) do
      FactoryBot.create(
        :user, permissions: [
          Permission.create(action: :read_objects, subject: Project.to_s, subject_id: project.id)
        ]
      )
    end

    let(:additional_rules) do
      [
        { actions: [:read], conditions: { id: project.id }, subject: ["Project"], inverted: false },
        { actions: [:read], conditions: { string_key: project.string_key }, subject: ["Project"], inverted: false },
        { actions: [:read], conditions: { project_id: project.id }, subject: ["PublishTarget"], inverted: false },
        { actions: [:read], conditions: { project: { string_key: project.string_key } }, subject: ["PublishTarget"], inverted: false },
        { actions: [:read], conditions: { project_id: project.id }, subject: ["FieldSet"], inverted: false },
        { actions: [:read], conditions: { project: { string_key: project.string_key } }, subject: ["FieldSet"], inverted: false },
        { actions: [:read_objects], conditions: { id: 1 }, subject: ["Project"], inverted: false },
        { actions: [:read_objects], conditions: { string_key: project.string_key }, subject: ["Project"], inverted: false }
      ]
    end

    it { is_expected.to be_able_to(:show, FactoryBot.create(:publish_target, project: project)) }
    it { is_expected.to be_able_to(:show, project) }
    it { is_expected.to be_able_to(:show, FactoryBot.create(:field_set, project: project)) }

    it { is_expected.not_to be_able_to(:update, FactoryBot.create(:field_set, project: project)) }
    it { is_expected.not_to be_able_to(:update, FactoryBot.create(:publish_target, project: project)) }

    it 'serializes correctly' do
      expect(ability.to_list).to match_array(
        base_rules.concat(additional_rules)
      )
    end
  end

  describe 'for digital object permissions' do
    subject { described_class.new(user) }

    let(:authorized_object) { FactoryBot.build(:digital_object_test_subclass, :with_sample_data, :with_lincoln_project) }
    let(:unauthorized_object) { FactoryBot.build(:digital_object_test_subclass, :with_sample_data, :with_minken_project) }
    let(:mixed_object) do
      obj = FactoryBot.build(:digital_object_test_subclass, :with_sample_data)
      obj.primary_project = authorized_object.primary_project
      obj.other_projects << unauthorized_object.primary_project
      obj
    end
    let(:authorized_project) { authorized_object.primary_project }
    let(:unauthorized_project) { unauthorized_object.primary_project }

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
    context 'when a user has the ability to assess_rights for a project' do
      let(:user) do
        FactoryBot.create(
          :user, permissions: [
            Permission.create(action: :assess_rights, subject: Project.to_s, subject_id: authorized_project.id)
          ]
        )
      end

      it { is_expected.to be_able_to(:assess_rights, authorized_project) }
      it { is_expected.not_to be_able_to(:assess_rights, unauthorized_project) }
    end
  end
end
