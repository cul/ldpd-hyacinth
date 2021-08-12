# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Users Requests', type: :feature, js: true do
  describe 'GET /users/new' do
    context 'when logged in user has appropriate permissions' do
      context 'when string_key is valid' do
        before do
          sign_in_user_manager
          visit "/ui/v1/users/new"
        end

        it 'returns correct response' do
          expect(page).to have_content('Create New User')
        end
      end
    end
  end
end
