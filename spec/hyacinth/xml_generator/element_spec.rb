# frozen_string_literal: true

require 'rails_helper'

describe Hyacinth::XmlGenerator::Element do
  let(:internal_fields) { { 'project.display_label' => 'Test Project' } }
  let(:xml_translation) { {} }
  let(:generator) { Hyacinth::XmlGenerator.new(nil, nil, nil, internal_fields) }

  let(:descriptive_metadata) do
    JSON.parse(file_fixture('xml_generator/descriptive_metadata.json').read)
  end

  let(:df_data) { descriptive_metadata["name"][0] }
  let(:element) { described_class.new(generator) }

  describe '#add_attributes' do
    let(:document) { Nokogiri::XML::Document.new }
    let(:ng_element) { element.create_ng_element(xml_translation, document) }
    before do
      element.add_attributes(xml_translation, df_data, ng_element)
    end

    context 'when attribute contains a render_if statement' do
      context 'when render_if false' do
        let(:xml_translation) do
          {
            'element' => 'mods:name',
            "attrs" => {
              "type" => "personal",
              "valueUNI" => "{{term.uni}}",
              "authority" => {
                "render_if" => {
                  "equal" => {
                    "term.authority" => "ISNI"
                  }
                },
                "val" => "fast"
              }
            }
          }
        end

        it "does not add attributes" do
          expect(ng_element.attribute("type").value).to eql "personal"
          expect(ng_element.attribute("valueUNI").value).to eql "jds1329"
        end
      end

      context 'when render_if true' do
        let(:xml_translation) do
          {
            'element' => 'mods:name',
            "attrs" => {
              "type" => "personal",
              "valueUNI" => "{{term.uni}}",
              "authority" => {
                "render_if" => {
                  "present" => ["term.uni"]
                },
                "val" => "fast"
              }
            }
          }
        end

        it "adds attributes if render_if is true" do
          expect(ng_element.attribute("type").value).to eql "personal"
          expect(ng_element.attribute("valueUNI").value).to eql "jds1329"
          expect(ng_element.attribute("authority").value).to eql "fast"
        end
      end
    end

    context 'when attributes listed in translation' do
      let(:xml_translation) do
        {
          'element' => 'mods:name',
          "attrs" => {
            "type" => "personal",
            "valueUNI" => "{{term.uni}}",
            "authority" => { "val" => "fast" },
            "xmlns:mods" => "http://www.loc.gov/mods/v3"
          }
        }
      end

      it 'adds all attributes element' do
        expect(ng_element.attribute("type").value).to eql "personal"
        expect(ng_element.attribute("valueUNI").value).to eql "jds1329"
        expect(ng_element.attribute("authority").value).to eql "fast"
      end

      it 'adds namespace' do
        expect(ng_element.namespaces['xmlns:mods']).to eql 'http://www.loc.gov/mods/v3'
      end
    end

    context 'when attributes not listed' do
      let(:xml_translation) { { 'element' => 'mods:name' } }

      it 'does not add any attributes' do
        expect(ng_element.attributes).to be_empty
      end
    end

    context "when attribute values blank" do
      let(:xml_translation) do
        {
          'element' => 'mods:name',
          'attrs' => {
            'type' => ' '
          }
        }
      end

      it 'does not add any attributes' do
        expect(ng_element.attributes).to be_empty
      end
    end
  end

  describe "#render?" do
    context 'when checking for multiple conditions' do
      let(:render_if) do
        {
          "present" => ["term.value", "term.uri"],
          "absent" => ["term.uni"]
        }
      end

      it 'return false when one is false' do
        expect(element.render?(render_if, df_data)).to be false
      end

      context 'when they are all true' do
        let(:df_data) { descriptive_metadata["name"][1] }

        it 'returns true' do
          expect(element.render?(render_if, df_data)).to be true
        end
      end
    end

    context 'when checking for fields that are present' do
      let(:df_data) { descriptive_metadata["title"][0] }

      it 'returns true if all fields are present' do
        render_if = { "present" => ["sort_portion", "non_sort_portion"] }
        expect(element.render?(render_if, df_data)).to be true
      end

      it "returns false if one field is missing" do
        render_if = { "present" => ["title_fake_field", "non_sort_portion"] }
        expect(element.render?(render_if, df_data)).to be false
      end
    end

    context "when checking for fields that are absent" do
      let(:df_data) { descriptive_metadata["title"][0] }

      it "returns true if all fields are absent" do
        render_if = { "absent" => ["title_fake_field", "title_fake_field_two"] }
        expect(element.render?(render_if, df_data)).to be true
      end

      it "returns false if one field is present" do
        render_if = { "absent" => ["title_fake_field", "non_sort_portion"] }
        expect(element.render?(render_if, df_data)).to be false
      end
    end

    context "when checking for fields that are equal" do
      it 'raises error when doing comparison with blank value' do
        render_if = { "equal" => { "term.uni" => "" } }
        expect { element.render?(render_if, df_data) }.to raise_error ArgumentError
      end

      it "returns true if all fields eql given value" do
        render_if = { "equal" => { "term.uni" => "jds1329", "term.value" => "Salinger, J. D." } }
        expect(element.render?(render_if, df_data)).to be true
      end

      context 'when one field does not eql the given value' do
        let(:df_data) { descriptive_metadata["name"][1] }

        it "returns false" do
          render_if = { "equal" => { "term.uni" => "jds1329", "term.value" => "Lincoln, Abraham" } }
          expect(element.render?(render_if, df_data)).to be false
        end
      end
    end

    context "when checking for fields that are not_equal" do
      it 'raises error when doing comparison with blank value' do
        render_if = { "not_equal" => { "term.uni" => "" } }
        expect { element.render?(render_if, df_data) }.to raise_error ArgumentError
      end

      it "returns false when field equals value given" do
        render_if = { "not_equal" => { "term.uni" => "jds1329" } }
        expect(element.render?(render_if, df_data)).to be false
      end

      it "returns true when field does not equal value given" do
        render_if = { "not_equal" => { "term.uni" => "jds132" } }
        expect(element.render?(render_if, df_data)).to be true
      end
    end

    context "when checking for fields that are equals_any_of" do
      it 'raises error when doing comparison with a non-array value' do
        render_if = { "equals_any_of" => { "term.uni" => "" } }
        expect { element.render?(render_if, df_data) }.to raise_error ArgumentError
      end

      it 'raises error when doing comparison with an empty array value' do
        render_if = { "equals_any_of" => { "term.uni" => [] } }
        expect { element.render?(render_if, df_data) }.to raise_error ArgumentError
      end

      it "returns true when field equals any of the given array values" do
        render_if = { "equals_any_of" => { "term.uni" => ["zzz", "jds1329"], "term.value" => ["Salinger, J. D.", "zzz"] } }
        expect(element.render?(render_if, df_data)).to be true
      end

      context 'when one field does not eql any of the given array values for that field' do
        let(:df_data) { descriptive_metadata["name"][1] }

        it "returns false" do
          render_if = { "equals_any_of" => { "term.uni" => ["jds1329"], "term.value" => ["zzz"] } }
          expect(element.render?(render_if, df_data)).to be false
        end
      end
    end

    context "when checking for fields that are equals_none_of" do
      it 'raises error when doing comparison with a non-array value' do
        render_if = { "equals_none_of" => { "term.uni" => "" } }
        expect { element.render?(render_if, df_data) }.to raise_error ArgumentError
      end

      it 'raises error when doing comparison with an empty array value' do
        render_if = { "equals_none_of" => { "term.uni" => [] } }
        expect { element.render?(render_if, df_data) }.to raise_error ArgumentError
      end

      it "returns false when field equals any of the array values given" do
        render_if = { "equals_none_of" => { "term.uni" => ["zzz", "jds1329"] } }
        expect(element.render?(render_if, df_data)).to be false
      end

      it "returns true when field equals none of array values given" do
        render_if = { "equals_none_of" => { "term.uni" => ["aaa", "bbb"] } }
        expect(element.render?(render_if, df_data)).to be true
      end
    end
  end
end
