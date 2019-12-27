# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Permission, type: :model do
  describe '#new' do
    context 'validates combination of action, subject, subject_id' do
      let(:user) { FactoryBot.create(:user) }
      let(:primary_project) { FactoryBot.create(:project) }
      let(:aggregator_project) { FactoryBot.create(:project, is_primary: false) }

      context 'when creating a system wide permission' do
        let(:permission) { Permission.new(action: Permission::MANAGE_USERS, user: user) }

        it 'saves object' do
          expect(permission.save).to be true
        end
      end

      context 'when creating a project permission' do
        let(:permission) { Permission.new(user: user, action: 'create_objects', subject: 'Project', subject_id: primary_project.id) }

        it 'saves object' do
          expect(permission.save).to be true
        end
      end

      context 'when creating an invalid permission' do
        let(:permission) { Permission.new(action: 'create_objects', user: user) }

        it 'does not save' do
          expect(permission.save).to be false
        end

        it 'returns correct error' do
          permission.save
          expect(permission.errors.full_messages).to include 'Action is invalid'
        end
      end

      context 'when creating invalid permissions for a primary project' do
        let(:invalid_action) { 'mahna mahna' }

        it "results in an error" do
          permission = Permission.new(user: user, action: invalid_action, subject: 'Project', subject_id: primary_project.id)
          expect(permission.save).to be false
          expect(permission.errors.full_messages).to include "Action #{invalid_action} is not allowed for a primary project"
        end
      end

      context 'when creating invalid permissions for an aggregator project' do
        it "results in an error" do
          Permission::PROJECT_ACTIONS_DISALLOWED_FOR_AGGREGATOR_PROJECTS.each do |disallowed_action|
            permission = Permission.new(user: user, action: disallowed_action, subject: 'Project', subject_id: aggregator_project.id)
            expect(permission.save).to be false
            expect(permission.errors.full_messages).to include "Action #{disallowed_action} is not allowed for an aggregator project"
          end
        end
      end
    end
  end

  context ".valid_project_action?" do
    context "for a primary project" do
      let(:is_primary_project) { true }

      it "returns true for valid actions" do
        Permission::PROJECT_ACTIONS.each do |action|
          expect(described_class.valid_project_action?(is_primary_project, action)).to eq(true)
        end
      end

      it "returns false for invalid actions" do
        expect(described_class.valid_project_action?(is_primary_project, 'mahna mahna')).to eq(false)
      end
    end

    context "for an aggregator project" do
      let(:is_primary_project) { false }

      it "returns true for valid actions" do
        Permission::AGGREGATOR_PROJECT_ACTIONS.each do |action|
          expect(described_class.valid_project_action?(is_primary_project, action)).to eq(true)
        end
      end

      it "returns false for invalid actions" do
        Permission::PROJECT_ACTIONS_DISALLOWED_FOR_AGGREGATOR_PROJECTS.each do |action|
          expect(described_class.valid_project_action?(is_primary_project, action)).to eq(false)
        end
      end
    end
  end
end
