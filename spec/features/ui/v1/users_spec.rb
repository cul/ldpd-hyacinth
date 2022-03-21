# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Users Requests', type: :feature, js: true do
  describe 'GET /ui/v1/users/new' do
    context 'when logged in user has appropriate permissions' do
      before { sign_in_user_manager }

      context 'when string_key is valid' do
        before { visit "/ui/v1/users/new" }

        it 'returns correct response' do
          expect(page).to have_content('Create New User')
        end
      end
    end
  end

  describe 'GET /ui/v1/users/:id/edit' do
    context 'when logged in user is an admin' do
      before { sign_in_user as: :administrator }

      context 'and the admin navigates to the edit page for a user' do
        let!(:user) { FactoryBot.create(:user) }
        before do
          visit "/ui/v1/users/#{user.uid}/edit"
        end

        specify 'the admin can click a button to log in as that user' do
          click_link_or_button('Switch to this user')
          within('#top-navbar') do
            expect(page).to have_content(user.full_name)
          end
        end
      end
    end
  end
end
