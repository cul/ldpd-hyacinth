# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Digital Objects System Data", type: :feature, js: true do
  include_context 'with stubbed search adapters'
  let(:alternate_primary_project) { FactoryBot.create(:project) }
  let(:other_project) { FactoryBot.create(:project) }
  let(:authorized_object) { FactoryBot.create(:item, :with_ascii_title, other_projects: Set.new([other_project])) }
  let(:authorized_project) { authorized_object.primary_project }
  let(:projects) { [authorized_project] }
  let(:request_url) { "/ui/v1/digital_objects/#{authorized_object.uid}/system_data" }

  describe 'GET /ui/v1/digital_objects/:id/system_data' do
    include_context 'with stubbed search result'
    before do
      sign_in_project_contributor actions: permissions_required, projects: projects
      visit request_url
    end

    context "logged in as reader" do
      let(:permissions_required) { [:read_objects] }
      it 'shows only project badges' do
        expect(page).to have_css('.inline-badge-list .badge', text: authorized_project.display_label)
      end
    end
    context "logged in as editor" do
      let(:permissions_required) { [:read_objects, :update_objects] }
      it 'shows primary badge and other project drop down' do
        expect(page).to have_css('.inline-badge-list .badge', text: authorized_project.display_label)
        expect(page).to have_field('Other Projects')
      end
      context 'that can create and delete objects' do
        let(:projects) { [authorized_project, alternate_primary_project] }
        let(:permissions_required) { [:read_objects, :update_objects, :create_objects, :delete_objects] }
        it 'shows selectable primary project and other projects' do
          expect(page).to have_field('Primary Project')
          expect(page).to have_field('Other Projects')
          # select uses the option label
          select(alternate_primary_project.display_label, from: 'Primary Project')
          find_button('Update').click
          # have_field(with:) uses the option value
          expect(page).to have_field('Primary Project', with: alternate_primary_project.string_key)
        end
      end
    end
    context 'when logged in user lacks appropriate permissions' do
      let(:permissions_required) { [] }
      it "shows an error message" do
        expect(page).to have_content("You are not authorized to access this page")
      end
    end
  end
end
