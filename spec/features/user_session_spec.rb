require 'rails_helper'

describe "User sign-in" do
  describe "Email-based sign-in" do
    it "works through the sign in screen", :js => true do
      visit '/users/sign_in'
      within("#new_user") do
        fill_in 'user_email', :with => 'hyacinth-test@library.columbia.edu'
        fill_in 'user_password', :with => 'iamthetest'
      end
      click_button 'Sign in'
      wait_for_ajax
      expect(page).to have_content 'New Digital Object'
    end

    context "when the user is inactive" do
      before do
        User.find_by(email: 'hyacinth-test@library.columbia.edu').update!(is_active: false)
      end
      it "sign in does not work", :js => true do
        visit '/users/sign_in'
        within("#new_user") do
          fill_in 'user_email', :with => 'hyacinth-test@library.columbia.edu'
          fill_in 'user_password', :with => 'iamthetest'
        end
        click_button 'Sign in'
        wait_for_ajax
        expect(page).to have_content 'This account is no longer active.'
      end
    end
  end
end
