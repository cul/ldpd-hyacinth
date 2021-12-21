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

      context 'refreshing search results with the search button' do
        before do
          FactoryBot.create(:item)
          visit '/ui/v1/digital_objects'
          expect(page).to have_selector('.digital-object-result', count: 1)
          FactoryBot.create(:item)
        end

        context 'starting from a "/digital_objects" with no query string parameters' do
          it 'finds the expected number of search results after a search-button-triggered result refresh' do
            expect(URI.parse(current_url).query).to be_blank
            click_link_or_button("Submit Search")
            expect(page).to have_selector('.digital-object-result', count: 2)
          end
        end

        context 'starting from a "/digital_objects" with query string parameters' do
          before do
            click_link_or_button("Submit Search") # This will assign default search query string params (searchType, orderBy, etc.)
          end
          it 'finds the expected number of search results after a search-button-triggered result refresh' do
            expect(URI.parse(current_url).query).to be_present
            click_link_or_button("Submit Search")
            expect(page).to have_selector('.digital-object-result', count: 2)
          end
        end
      end

      context 'clicking the clear search button' do
        before do
          FactoryBot.create(:item)
          visit '/ui/v1/digital_objects'
          within('#facet-sidebar') do
            click_link_or_button("Digital Object Type")
            click_link_or_button("item")
          end
        end

        it 'redirects to a url without any search query parameters' do
          expect(URI.parse(current_url).query).to be_present
          click_link_or_button("Clear Search")
          expect(URI.parse(current_url).query).to be_blank
        end
      end
    end
  end
end
