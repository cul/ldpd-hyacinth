# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Digital Object Show', solr: true, type: :feature, js: true do
  let(:uid) { SecureRandom.uuid }
  let(:item) { FactoryBot.create(:item, uid: uid) }
  let(:permissions_required) { [] }
  before { sign_in_project_contributor actions: permissions_required, projects: item.primary_project }

  describe 'GET /ui/v1/digital_objects/:uid' do
    context 'when logged in user has appropriate permissions' do
      let(:permissions_required) { [:read_objects] }
      context 'viewing an object by idenfifier' do
        let(:uid) { SecureRandom.uuid }
        before do
          visit "/ui/v1/digital_objects/#{item.uid}"
        end

        it 'redirects to metadata view' do
          expect(page).to have_current_path("/ui/v1/digital_objects/#{uid}/metadata")
        end
      end
    end
  end
end
