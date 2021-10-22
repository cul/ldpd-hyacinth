# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Project Enabled Dynamic Fields Show', type: :feature, js: true do
  include_context 'with stubbed search adapters'
  let(:project) { FactoryBot.create(:project, :legend_of_lincoln) }
  let(:digital_object_type) { 'item' }
  let(:permissions_required) { [] }
  let(:show_url) { "/ui/v1/projects/#{project.string_key}/enabled_dynamic_fields/#{digital_object_type}" }

  let(:dynamic_fields) do
    df1 = FactoryBot.create(:dynamic_field, string_key: 'field1', display_label: 'Field 1')
    df2 = FactoryBot.create(:dynamic_field, string_key: 'field2', display_label: 'Field 2', dynamic_field_group: df1.dynamic_field_group)
    [df1, df2]
  end
  let(:field_sets) do
    [
      FieldSet.create!(display_label: 'First field set', project: project),
      FieldSet.create!(display_label: 'Second field set', project: project)
    ]
  end
  before do
    EnabledDynamicField.create!(
      dynamic_field: dynamic_fields[0],
      project: project,
      digital_object_type: digital_object_type,
      default_value: 'banana',
      required: true,
      shareable: true,
      field_sets: field_sets
    )

    sign_in_project_contributor actions: permissions_required, projects: project
    visit show_url
  end

  describe "GET /ui/v1/projects/:string_key/enabled_dynamic_fields/:digital_object_type" do
    context 'when logged in user lacks appropriate permissions' do
      let(:permissions_required) { [] }
      it "does not display content requiring authorization" do
        expect(page).to have_css('h2', text: 'Page Not Found')
      end
    end

    context 'when logged in user has appropriate permissions' do
      let(:edit_url) { "#{show_url}/edit" }

      let(:permissions_required) { [:manage] }
      let(:enabled_dynamic_field_records) { EnabledDynamicField.includes(:dynamic_field).where(project: project, digital_object_type: digital_object_type) }
      let(:dynamic_fields_that_are_disabled) { DynamicField.where.not(id: enabled_dynamic_field_records.map { |edf| edf.dynamic_field.id }) }
      before do
        # Make sure we have examples of both enabled and disabled fields for the tests in this group
        expect(enabled_dynamic_field_records.length).to be_positive
        expect(dynamic_fields_that_are_disabled.length).to be_positive
      end
      it "has the expected read-only, unchecked checkbox for disabled fields" do
        dynamic_fields_that_are_disabled.each do |dynamic_field|
          within(".enabled-dynamic-field-configuration[data-field-path='#{dynamic_field.path}']") do
            expect(page).to have_css("span.badge", exact_text: dynamic_field.display_label)
            expect(page).to have_field("Enabled", disabled: true, checked: false)
          end
        end
      end
      it "has the expected read-only input values for enabled fields" do
        enabled_dynamic_field_records.each do |edf|
          dynamic_field = edf.dynamic_field
          within(".enabled-dynamic-field-configuration[data-field-path='#{dynamic_field.path}']") do
            expect(page).to have_css("span.badge", exact_text: dynamic_field.display_label)
            expect(page).to have_field("Enabled", disabled: true, checked: true)
            expect(page).to have_field("Shareable by Other Projects", disabled: true, checked: true)
            expect(page).to have_field("Required", disabled: true, checked: true)
            expect(page).to have_field("Default Value", disabled: true, with: 'banana')
            expect(page.find("#fieldSets-#{dynamic_field.id}").text.strip).to eq(field_sets.map(&:display_label).join("\n"))
          end
        end
      end
      it "links to the edit page via a button" do
        expect(page).to have_selector(:link_or_button, "Edit")
        click_link_or_button("Edit")
        expect(page).to have_current_path(edit_url)
      end
    end
  end
end
