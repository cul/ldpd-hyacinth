# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Digital Object Search', solr: true, type: :feature, js: true do
  describe 'GET /ui/v1/digital_objects' do
    context 'when logged in user has appropriate permissions' do
      before { sign_in_user as: :read_all }

      context 'searching for an object by idenfifier' do
        let(:item) { FactoryBot.create(:item, uid: SecureRandom.uuid) }
        before do
          visit "/ui/v1/digital_objects?searchType=IDENTIFIER&q=#{item.uid}"
        end

        it 'finds the expected item' do
          expect(page).to have_content("UID: #{item.uid}")
        end
        context 'continuing to search' do
          let(:another_item) { FactoryBot.create(:item, uid: SecureRandom.uuid) }
          before do
            fill_in('queryValue', with: another_item.uid)
            click_link_or_button("Submit Search")
          end
          it 'finds the expected item' do
            expect(page).to have_content("UID: #{another_item.uid}")
          end
          it 'can navigate back to original search' do
            expect(page).to have_content("UID: #{another_item.uid}")
            go_back
            expect(page).to have_content("UID: #{item.uid}")
          end
        end
        context 'navigating to a search result' do
          before do
            click_link(item.generate_display_label)
          end
          it 'links back to search' do
            expect(page).to have_link("Back to Search")
            return_to_search = page.find_link("Back to Search")
            expect(return_to_search[:href]).to include('searchType=IDENTIFIER')
            expect(return_to_search[:href]).to include("q=#{item.uid}")
          end
        end
      end
    end
  end
end
