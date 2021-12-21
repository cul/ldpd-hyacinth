# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Digital Object Edit', solr: true, type: :feature, js: true do
  let(:uid) { SecureRandom.uuid }
  let(:item) { FactoryBot.create(:item, uid: uid) }
  let(:permissions_required) { [] }
  before { sign_in_project_contributor actions: permissions_required, projects: item.primary_project }

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
          fill_in("Sort Portion", with: updated_title_value)
          find_button('Update').click
          # doing a find to make sure capybara waits for scripts run
          find('.digital-object-interface')
          expect(page).to have_current_path(show_path)
          expect(page).to have_content("Item: #{updated_title_value}")
        end
      end
      context 'and dynamic field data is updated with a language tag' do
        include_context 'with language subtag fixtures'
        let(:lang_subtags) { Hyacinth::Language::SubtagLoader.new(iana_en_fixture).load }
        let(:value_lang) { { 'tag' => 'en' } }
        let(:updated_field_value) { "Updated Alternative Title" }
        let(:updated_field_lang) { "sco" }
        let(:item) { lang_subtags && FactoryBot.create(:item, :with_ascii_dynamic_field_data, uid: uid, title: title_attribute, value_lang: value_lang) }
        before do
          page.find('.card-header', exact_text: 'Alternative Title')
          card_header = page.find('.card-header', exact_text: 'Alternative Title')
          within(card_header.sibling('.card-body')) do
            page.find_field('Value').set updated_field_value
            page.find_field('Value Language').set updated_field_lang
          end
          find_button('Update').click
          # doing a find to make sure capybara waits for scripts run
          find('.digital-object-interface')
        end
        it 'displays the updated values in the show view' do
          # doing a find to make sure capybara waits for scripts run
          card_header = page.find('.card-header', exact_text: 'Alternative Title')
          expect(page).to have_current_path(show_path)
          within(card_header.sibling('.card-body')) do
            expect(page).to have_css('[data-dynamic-field-string-key="value"] .field-value', exact_text: updated_field_value)
            expect(page).to have_css('[data-dynamic-field-string-key="value_lang"] .field-value', exact_text: updated_field_lang)
          end
        end
      end
    end
  end
end
