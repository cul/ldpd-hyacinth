# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Project Publish Targets Show', type: :feature, js: true do
  include_context 'with stubbed search adapters'
  let(:project) { FactoryBot.create(:project, :legend_of_lincoln, :with_publish_target) }
  let(:additional_publish_target) { FactoryBot.create(:publish_target) }
  let(:permissons_required) { [] }
  let(:show_url) { "/ui/v1/projects/#{project.string_key}/publish_targets" }
  before do
    sign_in_project_contributor to: permissions_required, project: project
    additional_publish_target
    visit show_url
  end

  describe 'GET /ui/v1/projects/:string_key/publish_targets' do
    let(:edit_url) { "#{show_url}/edit" }
    context 'when logged in user has appropriate permissions' do
      let(:permissions_required) { [:manage] }
      it "has badges and read-only checkboxes for enabled and prospective publish targets" do
        PublishTarget.all.each do |pt|
          within("##{pt.string_key}") do
            expect(page).to have_css("span.badge", exact_text: pt.string_key)
            checked = project.publish_targets.include?(pt)
            expect(page).to have_field("Enabled", disabled: true, checked: checked)
          end
        end
      end
      it "links to the edit page via a button" do
        expect(page).to have_selector(:link_or_button, "Edit")
        click_link_or_button("Edit")
        expect(page).to have_current_path(edit_url)
      end
    end
    context 'when logged in user lacks appropriate permissions' do
      let(:permissions_required) { [] }
      it "does not display content requiring authorization" do
        expect(page).to have_css('h2', text: 'Page Not Found')
      end
    end
  end
end
