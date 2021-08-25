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
end
