# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Digital Object Parents', type: :feature, js: true do
  include_context 'with stubbed search adapters'
  let(:item) { FactoryBot.create(:item, :with_ascii_title) }
  let(:another_item) { FactoryBot.create(:item, :with_ascii_title) }
  let(:asset) { FactoryBot.create(:asset, :with_main_resource, :with_ascii_title, parents_to_add: [item]) }
  let(:projects) { item.primary_project }
  let(:permissons_required) { [] }
  let(:request_url) { "/ui/v1/digital_objects/#{asset.uid}/parents" }

  before { sign_in_project_contributor actions: permissions_required, projects: projects }

  describe 'GET /ui/v1/digital_objects/:uid/parents' do
    context 'when logged in user has appropriate permissions' do
      let(:permissions_required) { [:read_objects] }
      before do
        visit request_url
      end
      it "lists current parents" do
        parents_header = page.find("h4", text: "Parent Digital Objects")
        expect(parents_header).not_to be_nil
        expect(page).to have_css('.parent', text: item.generate_display_label)
      end
    end
    context 'when a logged in user with update permission for an item tries to add it as a parent' do
      let(:permissions_required) { [:read_objects, :update_objects] }
      let(:projects) { [item.primary_project, another_item.primary_project] }
      before do
        visit request_url
        page.find_field('addParentInput').set ""
        fill_in("addParentInput", with: another_item.uid)
        find_button('addParentButton').click
      end
      it "page displays added parent label" do
        expect(page).to have_css('.parent', text: another_item.generate_display_label)
      end
    end
    context 'when an authorized user removes a parent' do
      let(:permissions_required) { [:read_objects, :update_objects] }
      before do
        visit request_url
        find_button("remove_parent_#{item.uid}").click
      end
      it "page does not display parent label" do
        expect(page).not_to have_css('.parent', text: item.generate_display_label)
      end
    end
    context 'when a logged in user tries to add a parent and they do not have update permission for that parent' do
      let(:permissions_required) { [:read_objects] }
      before do
        visit request_url
        page.find_field('addParentInput').set ""
        fill_in("addParentInput", with: another_item.uid)
        find_button('addParentButton').click
      end
      it "returns an error" do
        expect(page).to have_content("You do not have permission to add the specified parent-child relationship")
      end
    end
    context 'when an object has parents from different projects, and the logged in user has update permission for only one of the parents' do
      let(:permissions_required) { [:read_objects, :update_objects] }
      before do
        asset.parents_to_add << another_item
        asset.save
        visit request_url
      end
      it "does not display a remove button for the unauthorized parent" do
        expect(page).not_to have_button("remove_parent_#{another_item.uid}")
      end
      it "displays a remove button for the authorized parent" do
        expect(page).to have_button("remove_parent_#{item.uid}")
      end
    end
  end
end
