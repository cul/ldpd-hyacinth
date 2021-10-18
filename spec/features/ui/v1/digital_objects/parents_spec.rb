# frozen_string_literal: true

require 'rails_helper'

# TODO: Remove solr dependency when stubbed search from HYACINTH-819 is merged
RSpec.describe 'Digital Object Parents', solr: true, type: :feature, js: true do
  let(:item) { FactoryBot.create(:item, :with_ascii_title) }
  let(:asset) { FactoryBot.create(:asset, :with_main_resource, :with_ascii_title, parents_to_add: [item]) }

  let(:permissons_required) { [] }
  before { sign_in_project_contributor actions: permissions_required, projects: item.primary_project }

  describe 'GET /ui/v1/digital_objects/:uid/parents' do
    context 'when logged in user has appropriate permissions' do
      context 'viewing an object by identifier' do
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
    end
    context 'when logged in user does not have update permission on a parent' do
      context 'trying to add the parent' do
        let(:permissions_required) { [:read_objects] }
        let(:new_item) { FactoryBot.create(:item, :with_ascii_title) }
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
    end
    context 'when logged in user has update permission on one parent but not another' do
      context 'remove buttons' do
        let(:permissions_required) { [:read_objects] }
        let(:request_url) { "/ui/v1/digital_objects/#{asset.uid}/parents" }
        before do
          visit request_url
        end
        it "are displayed for the permitted parent" do
          parents_header = page.find("h4", text: "Parent Digital Objects")
          expect(parents_header).not_to be_nil
          expect(parents_header).to have_sibling(".card", text: item.generate_display_label)
        end
        it "and not displayed for the not permitted parent" do
          parents_header = page.find("h4", text: "Parent Digital Objects")
          expect(parents_header).not_to be_nil
          expect(parents_header).to have_sibling(".card", text: item.generate_display_label)
        end
      end
    end
  end
end
