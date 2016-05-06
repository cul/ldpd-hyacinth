require 'rails_helper'

describe DigitalObject::DynamicField, :type => :unit do
  let(:test_class) do
    _c = Class.new
    _c.send :include, DigitalObject::XmlDatastreamRendering
  end

  let(:digital_object) { test_class.new }
  let(:xml_translation_logic) do
    {
      'render_if' => {
        rule => condition
      }
    }
  end

  let(:present_data) { Hash['field', 'value'] }
  let(:absent_data) { Hash['not_field', 'value'] }

  describe '#should_render?' do

    context "presence required" do
      let(:rule) { 'present' }
      let(:condition) { ['field'] }
      context "data present" do
        subject { digital_object.should_render?(xml_translation_logic, present_data) }
        it { is_expected.to be }
      end
      context "data absent" do
        subject { digital_object.should_render?(xml_translation_logic, absent_data) }
        it { is_expected.not_to be }
      end
    end

    context "absence required" do
      let(:rule) { 'absent' }
      let(:condition) { ['field'] }
      context "data present" do
        subject { digital_object.should_render?(xml_translation_logic, present_data) }
        it { is_expected.not_to be }
      end
      context "data absent" do
        subject { digital_object.should_render?(xml_translation_logic, absent_data) }
        it { is_expected.to be }
      end
    end

    context "value required" do
      let(:rule) { 'equal' }
      let(:condition) { Hash['field', 'value'] }
      context "data present" do
        subject { digital_object.should_render?(xml_translation_logic, present_data) }
        it { is_expected.to be }
      end
      context "data absent" do
        subject { digital_object.should_render?(xml_translation_logic, absent_data) }
        it { is_expected.not_to be }
      end
    end
  end
end
