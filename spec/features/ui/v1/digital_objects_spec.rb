# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Digital Object Search', solr: true, type: :feature, js: true do
  describe 'GET /ui/v1/digital_objects' do
    context 'when logged in user has appropriate permissions' do
      before { sign_in_user as: :read_all }

      context 'searching for an object by idenfifier' do
        let(:uid) { SecureRandom.uuid }
        before do
          FactoryBot.create(:item, uid: uid)
          visit "/ui/v1/digital_objects?searchType=IDENTIFIER&q=#{uid}"
        end

        it 'finds the expected item' do
          expect(page).to have_content("UID: #{uid}")
        end
      end
    end
  end
end
