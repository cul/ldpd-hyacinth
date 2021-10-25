# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Digital Object Parents', type: :feature, js: true do
  include_context 'with stubbed search adapters'
  let(:item) { FactoryBot.create(:item, :with_ascii_title) }
  let(:asset) { FactoryBot.create(:asset, :with_main_resource, :with_ascii_title, parents_to_add: [item]) }

  let(:permissons_required) { [] }

  before { sign_in_project_contributor actions: permissions_required, projects: item.primary_project }

  describe 'GET /ui/v1/digital_objects/:uid/parents' do
    context 'when logged in user has appropriate permissions' do
      let(:permissions_required) { [:read_objects] }
      let(:request_url) { "/ui/v1/digital_objects/#{asset.uid}/parents" }
      before do
        visit request_url
      end
      it "lists current parents" do
        parents_header = page.find("h4", text: "Parent Digital Objects")
        expect(parents_header).not_to be_nil
        expect(parents_header).to have_sibling(".card", text: item.generate_display_label)
      end
    end
    context 'when a logged in user with object read permission tries to add a parent and they do not have update permission for that parent' do
      let(:new_item) { FactoryBot.create(:item, :with_ascii_title) }
      let(:permissions_required) { [:read_objects] }
      let(:request_url) { "/ui/v1/digital_objects/#{asset.uid}/parents" }
      before do
        visit request_url
        page.find_field('addParentInput').set ""
        fill_in("addParentInput", with: new_item.uid)
        find_button('addParentButton').click
      end
      it "returns an error" do
        expect(page).to have_content("You do not have permission to add the specified parent-child relationship")
      end
    end
    context 'when an object has two parents from different projects, and the logged in user only has update permission for one of the parent objects' do
      let(:new_item) { FactoryBot.create(:item, :with_ascii_title) }
      let(:permissions_required) { [:read_objects, :update_objects] }
      let(:request_url) { "/ui/v1/digital_objects/#{asset.uid}/parents" }
      before do
        asset.parents_to_add << new_item
        asset.save
        visit request_url
      end
      it "displays a remove button for the authorized parent" do
        expect(page).to have_button("remove_parent_#{item.uid}")
      end
      it "does not display a remove button for the unauthorized parent" do
        expect(page).not_to have_button("remove_parent_#{new_item.uid}")
      end
    end
  end
end
