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

      context 'when creating disallowed permissions for an aggregator project' do
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
end
