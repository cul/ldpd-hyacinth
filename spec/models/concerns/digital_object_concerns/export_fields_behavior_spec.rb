# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DigitalObjectConcerns::ExportFieldsBehavior do
  let!(:digital_object_with_sample_data) { FactoryBot.build(:digital_object_test_subclass, :with_sample_data, uid: 'unique-id-123') }

  describe "#internal_fields" do
    subject { digital_object_with_sample_data.internal_fields }

    it "includes uid when value is present" do
      is_expected.to include('uid' => digital_object_with_sample_data.uid)
    end

    it "includes primary_project.string_key when value is present" do
      is_expected.to include('primary_project.string_key' => 'great_project')
    end

    it "includes primary_project.display_label when value is present" do
      is_expected.to include('primary_project.display_label' => 'Great Project')
    end

    it "includes primary_project.project_url when value is present" do
      is_expected.to include('primary_project.project_url' => 'https://example.com/great_project')
    end
  end
  describe "#render_field_export" do
    let(:field_export_profile) { FieldExportProfile.find_by(name: 'descMetadata') }
    before do
      dynamic_field_group = FactoryBot.create(:dynamic_field_group, parent: DynamicFieldCategory.first)
      FactoryBot.create(:export_rule, dynamic_field_group: dynamic_field_group)
    end
    it "persists templated field exports to datastreams" do
      digital_object_with_sample_data.descriptive_metadata['name'] = [{ 'role' => "Farmer" }]
      actual_xml = digital_object_with_sample_data.render_field_export(field_export_profile)
      actual_xml.sub!(/^<\?.+\?>/, '') # remove XML declaration
      actual_xml.gsub!('mods:', '') # remove ns
      actual_xml.gsub!(/\s/, '') # remove whitespace
      expect(actual_xml).to eql("<mods><name>Farmer</name></mods>")
    end
    context "with title data" do
      include_context 'with english-adjacent language subtags'
      include_context 'with stubbed search adapters'
      let(:lang) { { 'tag' => 'sco' } }
      let(:non_sort_portion) { 'Ane' }
      let(:sort_portion) { 'Pleasant Satyre of the Thrie Estaitis' }
      let(:subtitle) { 'in Commendation of Vertew and Vituperation of Vyce' }
      let(:title) { { 'value_lang' => lang, 'value' => { 'non_sort_portion' => non_sort_portion, 'sort_portion' => sort_portion }, 'subtitle' => subtitle } }
      let(:item) { FactoryBot.create(:item, title: title) }
      let(:field_export_profile) { FactoryBot.create(:field_export_profile, :for_title_attribute) }
      let(:exported_data) { item.render_field_export(field_export_profile) }
      let(:exported_xml) { Nokogiri::XML(exported_data) }
      let(:xmlns) { { 'mods' => 'http://example.org/' } }
      it {
        expect(exported_xml.css("mods|titleInfo > mods|nonSort", xmlns).map(&:content)).to eql([title.dig('value', 'non_sort_portion')])
        expect(exported_xml.css("mods|titleInfo > mods|title", xmlns).map(&:content)).to eql([title.dig('value', 'sort_portion')])
        expect(exported_xml.css("mods|titleInfo > mods|subTitle", xmlns).map(&:content)).to eql([title['subtitle']])
        expect(exported_xml.css("mods|titleInfo[lang]", xmlns).map { |t| t['lang'] }).to eql([title.dig('value_lang', 'tag')])
      }
    end
    context "with language-tagged field data" do
      include_context 'with english-adjacent language subtags'
      include_context 'with stubbed search adapters'
      let(:lang) { 'sco' }
      let(:script) { 'Latn' }
      let(:lang_tag) { "#{lang}-#{script}" }
      let(:value_lang) { { 'tag' => lang_tag } }
      let(:value) { 'Ane Pleasant Satyre of the Thrie Estaitis' }
      let(:field_export_profile) { FactoryBot.create(:field_export_profile, :for_alternative_title_field) }
      let(:xmlns) { { 'mods' => 'http://example.org/' } }
      let(:item) { FactoryBot.create(:item, :with_ascii_dynamic_field_data, value: value, value_lang: value_lang) }
      # reload item for rehydrated term/language data
      let(:loaded_item) { DigitalObject::Item.find(item.id) }
      let(:exported_data) { loaded_item.render_field_export(field_export_profile) }
      let(:exported_xml) { Nokogiri::XML(exported_data) }
      before { FactoryBot.create(:export_rule, :for_alternative_title_field, field_export_profile: field_export_profile, dynamic_field_group: DynamicFieldGroup.first) }
      it {
        expect(exported_xml.css("mods|titleInfo[type='alternative'] > mods|title", xmlns).map(&:content)).to eql([value])
        expect(exported_xml.css("mods|titleInfo[type='alternative']", xmlns).map { |t| t['xml:lang'] }).to eql([lang_tag])
        expect(exported_xml.css("mods|titleInfo[type='alternative']", xmlns).map { |t| t['lang'] }).to eql([lang])
        expect(exported_xml.css("mods|titleInfo[type='alternative']", xmlns).map { |t| t['script'] }).to eql([script])
      }
    end
  end
end
