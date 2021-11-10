# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Project Publish Targets Edit', type: :feature, js: true do
  include_context 'with stubbed search adapters'
  let(:project) { FactoryBot.create(:project, :legend_of_lincoln, :with_publish_target) }
  let(:additional_publish_target) { FactoryBot.create(:publish_target) }
  let(:permissions_required) { [] }
  let(:show_url) { "/ui/v1/projects/#{project.string_key}/publish_targets" }
  let(:edit_url) { "#{show_url}/edit" }

  before do
    sign_in_project_contributor actions: permissions_required, projects: project
    additional_publish_target
    visit edit_url
  end

  describe 'GET /ui/v1/projects/:string_key/publish_targets/edit' do
    context 'when logged in user has appropriate permissions' do
      let(:inverted_selections) do
        selections = project.publish_targets.map { |pt| [pt.string_key, false] }.to_h
        selections[additional_publish_target.string_key] = true
        selections
      end
      let(:permissions_required) { [:manage] }
      it "has badges and editable checkboxes for enabled and prospective publish targets" do
        PublishTarget.all.each do |pt|
          within("##{pt.string_key}") do
            expect(page).to have_css("span.badge", exact_text: pt.string_key)
            checked = project.publish_targets.include?(pt)
            expect(page).to have_field("Enabled", checked: checked)
          end
        end
      end
      it "redirects to show page with updated data after clicking update button" do
        expectations = inverted_selections
        project.publish_targets.each { |pt| within("##{pt.string_key}") { uncheck("Enabled") } }
        within("##{additional_publish_target.string_key}") { check("Enabled") }
        click_on("Update")
        expect(page).to have_current_path(show_url)
        expectations.each { |id, checked| within("##{id}") { expect(page).to have_field("Enabled", disabled: true, checked: checked) } }
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
