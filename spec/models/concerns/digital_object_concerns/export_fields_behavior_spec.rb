require 'rails_helper'

RSpec.describe DigitalObjectConcerns::ExportFieldsBehavior do
  let(:digital_object_with_sample_data) { FactoryBot.build(:digital_object_test_subclass, :with_sample_data) }
  let(:uid_value) { 'unique-id-123' }
  before do
    allow(digital_object_with_sample_data).to receive(:metadata_attributes).and_return(
      {
        'uid' => Hyacinth::DigitalObject::TypeDef::String.new,
        'group' => Hyacinth::DigitalObject::TypeDef::Group.new
      }
    )
    allow(digital_object_with_sample_data).to receive(:uid).and_return(uid_value)
  end

  describe "#internal_fields" do
    subject { digital_object_with_sample_data.internal_fields }

    it "includes uid when value is present" do
      is_expected.to include('uid' => uid_value)
    end
  end
  describe "#render_field_export" do
    let(:field_export_profile) { FieldExportProfile.find_by(name: 'descMetadata') }
    before do
      FactoryBot.create(:export_rule)
    end
    it "persists templated field exports to datastreams" do
      digital_object_with_sample_data.dynamic_field_data['name'] = [{ 'role' => "Farmer" }]
      actual_xml = digital_object_with_sample_data.render_field_export(field_export_profile)
      actual_xml.sub!(/^<\?.+\?>/, '') # remove XML declaration
      actual_xml.gsub!('mods:', '') # remove ns
      actual_xml.gsub!(/\s/, '') # remove whitespace
      expect(actual_xml).to eql("<mods><name>Farmer</name></mods>")
    end
  end
end
