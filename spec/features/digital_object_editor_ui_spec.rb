require 'rails_helper'

describe "Digital Object Editor UI" do

  before(:each) do
    feature_spec_sign_in_admin_user
    wait_for_ajax
  end

  it "can create a new Digital Object", :js => true do
    expect(page).to have_content 'New Digital Object'

  end
end
