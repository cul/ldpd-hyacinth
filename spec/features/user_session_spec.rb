require 'rails_helper'

describe "Email-based user signin" do

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
end
