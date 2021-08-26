# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Digital Object Show', solr: true, type: :feature, js: true do
  let(:uid) { SecureRandom.uuid }
  let(:item) { FactoryBot.create(:item, uid: uid) }
  let(:permissons_required) { [] }
  before { sign_in_project_contributor to: permissions_required, project: item.primary_project }

  describe 'GET /ui/v1/digital_objects/:uid/metadata' do
    context 'when logged in user has appropriate permissions' do
      let(:permissions_required) { [:read_objects] }

      context 'viewing an object by idenfifier' do
        let(:title_attribute) { {} }
        let(:request_url) { "/ui/v1/digital_objects/#{item.uid}/metadata" }
        let(:item) { FactoryBot.create(:item, uid: uid, title: title_attribute) }
        before do
          visit request_url
        end
        context 'and title is blank' do
          it 'uses uid for label' do
            expect(page).to have_content("Item: #{uid}")
          end
        end
        context 'and title is present' do
          let(:title_value) { "Quizzes Aren't Specs" }
          let(:title_attribute) { { 'sort_portion' => title_value } }
          it 'uses title for label' do
            expect(page).to have_content("Item: #{title_value}")
          end
        end
        context 'and edit button is clicked' do
          let(:permissions_required) { [:read_objects, :update_objects] }
          let(:title_value) { "Quizzes Aren't Specs" }
          let(:title_attribute) { { 'sort_portion' => title_value } }
          let(:edit_path) { "/ui/v1/digital_objects/#{uid}/metadata/edit" }
          it 'goes to edit view' do
            expect(page).to have_css('a[aria-label="Edit"]')
            find('a[aria-label="Edit"]').click
            # do a find to make sure scripts run
            find('.digital-object-interface')
            expect(page).to have_current_path(edit_path)
          end
        end
      end
    end
  end
end
