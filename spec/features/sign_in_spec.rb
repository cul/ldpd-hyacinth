require 'rails_helper'

describe "The sign in page", type: :feature do
  context "for a user who is not logged in" do
    it "displays the expected welcome message", js: true do
      visit('/users/sign_in')
      expect(page).to have_content 'Welcome to Hyacinth!'
    end
  end
end
