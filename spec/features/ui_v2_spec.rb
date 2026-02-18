require 'rails_helper'

describe 'React application rendering', type: :feature, js: true do
  context 'when user is not authenticated' do
    it 'shows "Not Signed In" when visiting /ui/v2' do
      visit '/ui/v2'

      expect(page).to have_content 'Signed In'
      expect(page).to have_content 'You must be signed in to view this page.'
    end

    it 'shows "Not Signed In" when visiting a nested React route' do
      visit '/ui/v2/users'

      expect(page).to have_content 'Not Signed In'
    end

    it 'does not render the React application' do
      visit '/ui/v2'

      expect(page).not_to have_css '#root'
    end
  end

  context 'when user is authenticated' do
    let(:user) { FactoryBot.create(:user, first_name: 'Test', last_name: 'User') }

    before do
      login_as(user)
    end

    it 'renders the React application' do
      visit '/ui/v2'

      expect(page).not_to have_content 'Loading...'
      expect(page).to have_css '#root'
    end

    it 'shows user\'s name when visiting /ui/v2' do
      visit '/ui/v2'

      # Wait for React app to load the user info and update the UI
      expect(page).not_to have_content 'Loading user...'

      # The user's name is in a NavDropdown which may be inside an Offcanvas on smaller viewports.
      # We need to use find with visible: false to locate it in the DOM regardless of CSS visibility.
      expect(find('.dropdown-toggle.nav-link', text: 'Test User', visible: false)).to be_truthy
    end
  end
end

