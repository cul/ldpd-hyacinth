# frozen_string_literal: true

require 'rails_helper'
require 'cancan/matchers'

RSpec.describe Ability, type: :model do
  subject(:ability) { described_class.new(user) }
  let(:base_user_rules) do
    [
      { actions: [:read, :update], conditions: { id: user.id }, subject: ["User"], inverted: false },
      { actions: [:read, :update], conditions: { uid: user.uid }, subject: ["User"], inverted: false },
      { actions: [:read, :create], conditions: {}, subject: ["Term"], inverted: false },
      { actions: [:read], conditions: {}, subject: ["Vocabulary"], inverted: false },
      { actions: [:read], conditions: {}, subject: ["DynamicFieldCategory"], inverted: false },
      { actions: [:read], conditions: {}, subject: ["PublishTarget"], inverted: false },
      { actions: [:create], conditions: {}, subject: ["BatchExport"], inverted: false },
      { actions: [:read, :destroy], conditions: { user_id: user.id }, subject: ["BatchExport"], inverted: false },
      { actions: [:create], conditions: {}, subject: ["BatchImport"], inverted: false },
      { actions: [:read, :update, :destroy], conditions: { user_id: user.id }, subject: ["BatchImport"], inverted: false }
    ]
  end

  context 'when user is nil (i.e. not logged in)' do
    let(:user) { nil }

    it 'has no abilities' do
      expect(ability.permissions[:can]).to be_blank
      expect(ability.permissions[:cannot]).to be_blank
    end
  end

  describe 'when basic user is logged in' do
    let(:user) { FactoryBot.create(:user) }

    it 'has the expected base abilities' do
      expect(ability.to_list).to eq(base_user_rules)
    end
  end

  describe 'when user is administrator' do
    let(:user) { FactoryBot.create(:user, is_admin: true) }

    it { is_expected.to be_able_to(:manage, :all) }
    it { is_expected.to be_able_to(:manage, Vocabulary) }
    it { is_expected.to be_able_to(:manage, DigitalObject) }
    it { is_expected.to be_able_to(:update, Project) }
    it { is_expected.to be_able_to(:manage, PublishTarget) }

    it 'serializes correctly' do
      expect(ability.to_list).to match([{ actions: [:manage], conditions: {}, subject: [:all], inverted: false }])
    end
  end

  describe 'when user is user manager' do
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
        base_user_rules.concat([{ actions: [:manage], conditions: {}, subject: ['User'], inverted: false }])
      )
    end
  end

  describe 'when user is resource request manager' do
    let(:user) do
      FactoryBot.create(
        :user, permissions: [Permission.create(action: Permission::MANAGE_RESOURCE_REQUESTS)]
      )
    end

    it { is_expected.not_to be_able_to(:manage, :all) }
    it { is_expected.to be_able_to(:manage, ResourceRequest) }
    it { is_expected.to be_able_to(:read, ResourceRequest) }
    it { is_expected.to be_able_to(:update, ResourceRequest) }
    it { is_expected.to be_able_to(:delete, ResourceRequest) }

    it 'serializes correctly' do
      expect(ability.to_list).to match_array(
        base_user_rules.concat([{ actions: [:manage], conditions: {}, subject: ['ResourceRequest'], inverted: false }])
      )
    end
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
        base_user_rules.concat(additional_rules)
      )
    end
  end

  describe 'when user is logged in' do
    let(:user) { FactoryBot.create(:user) }

    it { is_expected.to be_able_to(:read, user) }
    it { is_expected.to be_able_to(:update, user) }
    it { is_expected.to be_able_to(:read, PublishTarget) }

    it { is_expected.not_to be_able_to(:manage, User) }
    it { is_expected.not_to be_able_to(:update, PublishTarget) }

    it 'serializes correctly' do
      expect(ability.to_list).to match(base_user_rules)
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
    it { is_expected.to be_able_to(:read, FieldSet) }
    it { is_expected.not_to be_able_to(:update, Project) }
    it { is_expected.to be_able_to(:read, PublishTarget) }
    it { is_expected.to be_able_to(:read, DigitalObject) }
    it { is_expected.not_to be_able_to(:update, DigitalObject) }
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
    it { is_expected.to be_able_to(:assess_rights, Project) }
    it { is_expected.to be_able_to(:read, DigitalObject) }
    it { is_expected.to be_able_to(:update, DigitalObject) }
    it { is_expected.to be_able_to(:destroy, DigitalObject) }
    it { is_expected.to be_able_to(:create, DigitalObject) }
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

    let(:additional_rules) do
      [
        { actions: [:read], conditions: { id: project.id }, subject: ["Project"], inverted: false },
        { actions: [:read], conditions: { string_key: project.string_key }, subject: ["Project"], inverted: false },
        { actions: [:read], conditions: { project_id: project.id }, subject: ["FieldSet"], inverted: false },
        { actions: [:read], conditions: { project: { string_key: project.string_key } }, subject: ["FieldSet"], inverted: false },
        { actions: [:read_objects], conditions: { id: 1 }, subject: ["Project"], inverted: false },
        { actions: [:read_objects], conditions: { string_key: project.string_key }, subject: ["Project"], inverted: false }
      ]
    end

    it { is_expected.to be_able_to(:show, project) }
    it { is_expected.to be_able_to(:show, FactoryBot.create(:field_set, project: project)) }

    it { is_expected.not_to be_able_to(:update, FactoryBot.create(:field_set, project: project)) }

    it 'serializes correctly' do
      expect(ability.to_list).to match_array(
        base_user_rules.concat(additional_rules)
      )
    end
  end

  describe 'for digital object permissions' do
    subject { described_class.new(user) }

    let(:authorized_object) { FactoryBot.build(:digital_object_test_subclass, :with_sample_data) }
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
