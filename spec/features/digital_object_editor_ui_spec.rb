require 'rails_helper'

describe "Digital Object Editor UI", type: :feature do
  before { sign_in_admin_user }
  it "displays the expected welcome message", js: true do
    visit('/digital_objects')
    expect(page).to have_content 'New Digital Object'
  end
end
