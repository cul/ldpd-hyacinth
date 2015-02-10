require 'rails_helper'

describe "Non-logged-in user" do
  it "gets an unauthorized response when trying to access the DigitalObjects index page", :js => true do
    visit '/digital_objects/index'
    expect(page).to have_content 'Not Signed In'
  end
end

describe "Permission-restricted resources" do

  let(:non_admin_user) { FactoryGirl.create(:non_admin_user) }

  it "does something", :js => true do
    #visit '/users/sign_in'
    #expect(page).to have_content 'New Digital Object'
  end
end
