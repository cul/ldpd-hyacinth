# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Digital Object Preserve and Publish", type: :feature, js: true do
  include_context 'with stubbed search adapters'

  let(:project) { FactoryBot.create(:project, :with_publish_targets) }
  let(:available_publish_targets) { project.publish_targets.to_a }
  let(:authorized_object) { FactoryBot.create(:item, :with_ascii_title, primary_project: project) }
  let(:request_url) { "/ui/v1/digital_objects/#{authorized_object.uid}/preserve_publish" }

  describe 'GET /ui/v1/digital_objects/:id/preserve_publish' do
    include_context 'with stubbed search result'
    before do
      sign_in_project_contributor actions: permissions_required, projects: [project]
      visit request_url
    end

    context 'when user does not have any permissions for the digital object' do
      let(:permissions_required) { [] }
      it "shows an authorization error message" do
        expect(page).to have_content("You are not authorized to access this page")
      end
    end
    context "user only has read permission" do
      let(:permissions_required) { [:read_objects] }
      it 'does not show "Run Publish / Unpublish Operations" or "Preserve Only" buttons' do
        expect(page).not_to have_css('button', text: 'Run Publish / Unpublish Operations')
        expect(page).not_to have_css('button', text: 'Preserve Only')
      end
    end
    context "user has required permissions" do
      let(:permissions_required) { [:read_objects, :publish_objects] }
      it 'shows "Run Publish / Unpublish Operations" and "Preserve Only" buttons' do
        expect(page).to have_css('button', text: 'Run Publish / Unpublish Operations')
        expect(page).to have_css('button', text: 'Preserve Only')
      end

      it 'can perform a standalone preserve operation (without a publish)' do
        expect(page).not_to have_css('.last-preserved', text: 'Not preserved')
        click_on('Preserve Only')
        expect(page).to have_css('.last-preserved', text: 'Last preserved -')
        expect(page).to have_css('.last-published', text: 'Not published')
      end

      it 'can perform a publish operation (which also preserves)' do
        expect(page).not_to have_css('.last-published', text: 'Not published')
        available_publish_targets.each do |available_publish_target|
          find(%(label[for="#{available_publish_target.string_key}-publish"])).click
        end
        click_on('Run Publish / Unpublish Operations')
        expect(page).to have_css('.last-published', text: 'Last published -')
        expect(page).to have_css('.last-preserved', text: 'Last preserved -')
      end

      context "when object has been previously published" do
        let(:authorized_object) do
          obj = FactoryBot.create(:item, :with_ascii_title, primary_project: project)
          obj.preserve # must preserve before publish
          obj.perform_publish_changes(publish_to: available_publish_targets)
          obj
        end
        it 'can perform an unpublish operation' do
          expect(page).to have_css('.last-published', text: 'Last published -')
          available_publish_targets.each do |available_publish_target|
            find(%(label[for="#{available_publish_target.string_key}-unpublish"])).click
          end
          click_on('Run Publish / Unpublish Operations')
          expect(page).not_to have_css('.last-published', text: 'Not published')
        end
      end
    end
  end
end
