require 'rails_helper'

RSpec.describe Permission, type: :model do
  describe '#new' do
    context 'validates combination of action, subject, subject_id' do
      let(:user) { FactoryBot.create(:user) }

      context 'when creating a system wide permission' do
        let(:permission) { Permission.new(action: Permission::MANAGE_USERS, user: user) }

        it 'saves object' do
          expect(permission.save).to be true
        end
      end

      context 'when creating a project permission' do
        let(:permission) { Permission.new(user: user, action: 'create_objects', subject: 'Project', subject_id: '1') }

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
    end
  end
end
