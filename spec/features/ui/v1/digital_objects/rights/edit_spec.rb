# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Digital Object Rights Edit', type: :feature, js: true, solr: true do
  let(:uid) { SecureRandom.uuid }
  let(:permissions_required) { [:read_objects, :assess_rights] }
  let(:well_known_title_value) { "Best Item Ever" }
  let(:well_known_label_value) { "The #{well_known_title_value}" }
  let(:request_url) { "/ui/v1/digital_objects/#{item.uid}/rights/edit" }
  let(:item) { FactoryBot.create(:item, :with_rights, :with_ascii_title, uid: uid) }
  before { sign_in_project_contributor to: permissions_required, project: item.primary_project }

  describe 'GET /ui/v1/digital_objects/:uid/rights/edit' do
    before do
      visit request_url
    end
    context 'when logged in user has appropriate permissions' do
      it "shows the title data from the metadata attribute in a read-only field" do
        expect(page).to have_content("Item: #{well_known_label_value}")
        expect(page).to have_field('Title', with: well_known_title_value, disabled: true)
      end
    end
    context 'when logged in user lacks appropriate permissions' do
      let(:permissions_required) { [:read_objects] }
      it "shows an error message" do
        expect(page).to have_content("Page Not Found")
      end
    end
  end
end
