# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Batch Imports Requests', type: :feature, js: true do
  describe 'GET /ui/v1/batch_imports' do
    context 'when logged in user has appropriate permissions' do
      before { sign_in_user as: :administrator }

      context 'no imports have been created' do
        before { visit "/ui/v1/batch_imports" }

        it 'returns correct response' do
          expect(page).to have_content('No Batch Imports have been created.')
        end
      end

      context 'an import has been created' do
        let(:batch_import) { FactoryBot.create(:batch_import, :with_digital_object_import) }
        before do
          batch_import
          visit "/ui/v1/batch_imports"
        end

        it 'returns correct response' do
          expect(page).to have_content("Import ID: #{batch_import.id}")
          expect(page).to have_link("View", href: "batch_imports/#{batch_import.id}")
        end
      end
    end
  end

  describe 'GET /ui/v1/batch_imports/:id' do
    context 'when logged in user has appropriate permissions' do
      before { sign_in_user as: :administrator }

      context 'an import has been created' do
        let(:batch_import) { FactoryBot.create(:batch_import, :with_digital_object_import) }
        before do
          visit "/ui/v1/batch_imports/#{batch_import.id}"
        end

        it 'returns correct response' do
          expect(page).to have_content("Batch Import: #{batch_import.id}")
          expect(page).to have_link('View Details »', href: "/ui/v1/batch_imports/#{batch_import.id}/digital_object_imports")
        end
      end
    end
  end

  describe 'GET /ui/v1/batch_imports/:id/digital_object_imports' do
    context 'when logged in user has appropriate permissions' do
      before { sign_in_user as: :administrator }

      context 'an import has been created' do
        let(:batch_import) { FactoryBot.create(:batch_import, :with_digital_object_import) }
        before do
          visit "/ui/v1/batch_imports/#{batch_import.id}/digital_object_imports"
        end

        it 'returns correct response' do
          expect(page).to have_content("Status of Batch Import")
          expect(page).to have_link('ALL')
        end
      end
    end
  end
end
