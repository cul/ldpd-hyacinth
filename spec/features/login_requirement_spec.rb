require 'rails_helper'

describe "Login requirement", type: :feature do
  let(:page_that_requires_login_to_view) { '/digital_objects' }

  context "when a user is logged in" do
    before { request_test_sign_in_admin_user }

    it "displays the page content", js: true do
      visit(page_that_requires_login_to_view)
      expect(page).to have_content 'New Digital Object'
    end
  end

  context "when a user is NOT logged in" do
    it "the user is shown a 'Not Signed In' message", js: true do
      visit(page_that_requires_login_to_view)
      expect(page).not_to have_content 'New Digital Object'
      expect(page).to have_content 'Not Signed In'
    end
  end
end
