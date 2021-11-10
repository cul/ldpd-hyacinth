# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Project Enabled Dynamic Fields Edit', type: :feature, js: true do
  include_context 'with stubbed search adapters'
  let(:project) { FactoryBot.create(:project, :legend_of_lincoln) }
  let(:digital_object_type) { 'item' }
  let(:permissions_required) { [] }
  let(:show_url) { "/ui/v1/projects/#{project.string_key}/enabled_dynamic_fields/#{digital_object_type}" }
  let(:edit_url) { "#{show_url}/edit" }

  let!(:dynamic_field) { FactoryBot.create(:dynamic_field, string_key: 'field1', display_label: 'Field 1') }
  let!(:field_set) { FieldSet.create!(display_label: 'First field set', project: project) }

  before { sign_in_project_contributor actions: permissions_required, projects: project }

  describe "GET /ui/v1/projects/:string_key/enabled_dynamic_fields/:digital_object_type/edit" do
    context 'when logged in user lacks appropriate permissions' do
      let(:permissions_required) { [] }
      before { visit edit_url }
      it "does not display content requiring authorization" do
        expect(page).to have_css('h2', text: 'Page Not Found')
      end
    end

    context 'when logged in user has appropriate permissions' do
      let(:permissions_required) { [:manage] }
      let(:already_enabled_field) { nil }

      before do
        already_enabled_field
        visit edit_url
      end

      context "can enable and configure a project enabled dynamic field" do
        before do
          within(".enabled-dynamic-field-configuration[data-field-path='#{dynamic_field.path}']") do
            find_field('Enabled').set(true)
            find_field('Shareable by Other Projects').set(true)
            find_field('Required').set(true)
            find_field('Default Value').set('banana')
            within("#fieldSets-#{dynamic_field.id}") do
              page.find('div[class*="-placeholder"]').click
              page.driver.browser.switch_to.active_element.send_keys :enter
            end
          end
          click_link_or_button("Update")
        end
        it "successfully saves the configuration" do
          expect(page).to have_current_path(show_url)
          within(".enabled-dynamic-field-configuration[data-field-path='#{dynamic_field.path}']") do
            expect(page).to have_css("span.badge", exact_text: dynamic_field.display_label)
            expect(page).to have_field("Enabled", disabled: true, checked: true)
            expect(page).to have_field("Shareable by Other Projects", disabled: true, checked: true)
            expect(page).to have_field("Required", disabled: true, checked: true)
            expect(page).to have_field("Default Value", disabled: true, with: 'banana')
            expect(page.find("#fieldSets-#{dynamic_field.id}").text.strip).to eq(field_set.display_label)
          end
        end
      end

      context "when disabling a project enabled dynamic field" do
        let(:already_enabled_field) { EnabledDynamicField.create!(dynamic_field: dynamic_field, project: project, digital_object_type: digital_object_type) }

        before do
          within(".enabled-dynamic-field-configuration[data-field-path='#{dynamic_field.path}']") do
            expect(page).to have_field("Enabled", checked: true)
            find_field('Enabled').set(false)
            expect(page).to have_field("Enabled", checked: false)
          end
        end

        context 'when the field is NOT in use by a record in the project' do
          before do
            allow(Hyacinth::Config.digital_object_search_adapter).to receive(:field_used_in_project?).and_return false
            click_link_or_button("Update")
          end
          it "successfully saves the disabled field state" do
            expect(page).to have_current_path(show_url)
            within(".enabled-dynamic-field-configuration[data-field-path='#{dynamic_field.path}']") do
              expect(page).to have_css("span.badge", exact_text: dynamic_field.display_label)
              expect(page).to have_field("Enabled", disabled: true, checked: false)
            end
          end
        end

        context 'when the field IS in use by a record in the project' do
          before do
            allow(Hyacinth::Config.digital_object_search_adapter).to receive(:field_used_in_project?).and_return true
            click_link_or_button("Update")
          end
          it "does not save, and displays the expected error message" do
            expect(page).to have_current_path(edit_url)
            expect(page).to have_css(
              ".alert",
              text: "Cannot disable #{dynamic_field.display_label} because it's used by one or more #{digital_object_type.pluralize} in #{project.display_label} (path=#{dynamic_field.path})"
            )
          end
        end
      end

      it "links to the show page via cancel button" do
        expect(page).to have_selector(:link_or_button, "Cancel")
        click_link_or_button("Cancel")
        expect(page).to have_current_path(show_url)
      end
    end
  end
end
