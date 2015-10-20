require 'rails_helper'

describe "Non-logged-in user" do
  it "gets an unauthorized response when trying to access the DigitalObjects index page", :js => true do
    visit '/digital_objects/index'
    expect(page).to have_content 'Not Signed In'
  end
end

describe "Permission-restricted resources" do

  it "does something", :js => true do
    feature_spec_sign_in_admin_user
    wait_for_ajax
    expect(page).to have_content 'New Digital Object'
  end
end
