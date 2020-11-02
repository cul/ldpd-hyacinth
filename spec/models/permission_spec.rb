# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Permission, type: :model do
  describe '#new' do
    context 'validates combination of action, subject, subject_id' do
      let(:user) { FactoryBot.create(:user) }
      let(:project) { FactoryBot.create(:project) }

      context 'when creating a system wide permission' do
        let(:permission) { Permission.new(action: Permission::MANAGE_USERS, user: user) }

        it 'saves object' do
          expect(permission.save).to be true
        end
      end

      context 'when creating a project permission' do
        let(:permission) { Permission.new(user: user, action: 'create_objects', subject: 'Project', subject_id: project.id) }

        it 'saves object' do
          expect(permission.save).to be true
        end

        context 'with a missing subject_id' do
          let(:permission) { Permission.new(action: 'create_objects', user: user) }

          it 'does not save' do
            expect(permission.save).to be false
          end

          it 'returns correct error' do
            permission.save
            expect(permission.errors.full_messages).to include 'Action is invalid'
          end
        end

        context 'with an invalid action' do
          let(:invalid_action) { 'mahna mahna' }

          it "results in an error" do
            permission = Permission.new(user: user, action: invalid_action, subject: 'Project', subject_id: project.id)
            expect(permission.save).to be false
            expect(permission.errors.full_messages).to include "Action #{invalid_action} is not allowed for a project"
          end
        end
      end
    end
  end

  context ".valid_project_action?" do
    Permission::PROJECT_ACTIONS.each do |action|
      it "returns true for valid action: #{action}" do
        expect(described_class.valid_project_action?(action)).to eq(true)
      end
    end

    it "returns false for an invalid action" do
      expect(described_class.valid_project_action?('mahna mahna')).to eq(false)
    end
  end
end
