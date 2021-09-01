# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Digital Object Edit', solr: true, type: :feature, js: true do
  let(:uid) { SecureRandom.uuid }
  let(:item) { FactoryBot.create(:item, uid: uid) }
  let(:permissons_required) { [] }
  before { sign_in_project_contributor to: permissions_required, project: item.primary_project }

  describe 'GET /ui/v1/digital_objects/:uid/metadata/edit' do
    context 'when logged in user has appropriate permissions' do
      let(:permissions_required) { [:read_objects, :update_objects] }
      let(:original_title_value) { "Quizzes Aren't Specs" }
      let(:updated_title_value) { "Quizzes Are Tests" }
      let(:title_attribute) { { 'value' => { 'sort_portion' => original_title_value } } }
      let(:request_url) { "/ui/v1/digital_objects/#{item.uid}/metadata/edit" }
      let(:show_path) { "/ui/v1/digital_objects/#{item.uid}/metadata" }
      let(:item) { FactoryBot.create(:item, uid: uid, title: title_attribute) }
      before do
        visit request_url
        expect(page).to have_content("Item: #{original_title_value}")
      end
      context 'and title data is updated with valid data' do
        let(:show_path) { "/ui/v1/digital_objects/#{uid}/metadata" }
        it 'goes to show view' do
          # Selenium appears to be appending to current value with fill_in, so setting to blank first
          page.find_field('Sort Portion').set ""
          fill_in("Sort Portion", with: updated_title_value)
          find_button('Update').click
          # do a find to make sure scripts run
          find('.digital-object-interface')
          expect(page).to have_current_path(show_path)
          expect(page).to have_content("Item: #{updated_title_value}")
        end
      end
    end
  end
end
