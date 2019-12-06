require 'rails_helper'

describe Hyacinth::XMLGenerator::Element do
  let(:internal_fields) { { 'project.display_label' => 'Test Project' } }
  let(:xml_translation) { {} }
  let(:generator) { Hyacinth::XMLGenerator.new(nil, nil, nil, internal_fields) }

  let(:dynamic_field_data) do
    JSON.parse(fixture('lib/hyacinth/xml_generator/test_dynamic_field_data.json').read)
  end

  let(:df_data) { dynamic_field_data["name"][0] }
  let(:element) { described_class.new(generator, nil, xml_translation, df_data) }

  describe '#add_attributes' do
    before do
      allow(generator).to receive(:document).and_return(Nokogiri::XML::Document.new)
      element.create_ng_element
      element.add_attributes
    end

    context 'when attribute contains a render_if statement' do
      context 'when render_if false' do
        let(:xml_translation) do
          {
            'element' => 'mods:name',
            "attrs" => {
              "type" => "personal",
              "valueUNI" => "{{name_term.uni}}",
              "authority" => {
                "render_if" => {
                  "equal" => {
                    "name_term.authority" => "ISNI"
                  }
                },
                "val" => "fast"
              }
            }
          }
        end

        it "does not add attributes" do
          expect(element.ng_element.attribute("type").value).to eql "personal"
          expect(element.ng_element.attribute("valueUNI").value).to eql "jds1329"
        end
      end

      context 'when render_if true' do
        let(:xml_translation) do
          {
            'element' => 'mods:name',
            "attrs" => {
              "type" => "personal",
              "valueUNI" => "{{name_term.uni}}",
              "authority" => {
                "render_if" => {
                  "present" => ["name_term.uni"],
                },
                "val" => "fast"
              },
            }
          }
        end

        it "adds attributes if render_if is true" do
          expect(element.ng_element.attribute("type").value).to eql "personal"
          expect(element.ng_element.attribute("valueUNI").value).to eql "jds1329"
          expect(element.ng_element.attribute("authority").value).to eql "fast"
        end
      end
    end

    context 'when attributes listed in translation' do
      let(:xml_translation) do
        {
          'element' => 'mods:name',
          "attrs" => {
            "type" => "personal",
            "valueUNI" => "{{name_term.uni}}",
            "authority" => { "val" => "fast" },
            "xmlns:mods" => "http://www.loc.gov/mods/v3"
          }
        }
      end

      it 'adds all attributes element' do
        expect(element.ng_element.attribute("type").value).to eql "personal"
        expect(element.ng_element.attribute("valueUNI").value).to eql "jds1329"
        expect(element.ng_element.attribute("authority").value).to eql "fast"
      end

      it 'adds namespace' do
        expect(element.ng_element.namespaces['xmlns:mods']).to eql 'http://www.loc.gov/mods/v3'
      end
    end

    context 'when attributes not listed' do
      let(:xml_translation) { { 'element' => 'mods:name' } }

      it 'does not add any attributes' do
        expect(element.ng_element.attributes).to be_empty
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
        expect(element.ng_element.attributes).to be_empty
      end
    end
  end

  describe '#generate_field_val' do
    it 'returns string' do
      expect(element.generate_field_val("foobar")).to eql 'foobar'
    end

    it 'returns val' do
      expect(element.generate_field_val({"val" => "foobar"})).to eql 'foobar'
    end

    it 'returns calculated ternary result' do
      value = { "ternary" => ["name_term.value", "name_term.value", ""] }
      expect(element).to receive(:render_output_of_ternary).with(value["ternary"])
      element.generate_field_val(value)
    end

    it 'returns joined string' do
      value = { "join" => { "delimiter" => ",", "pieces" => ["{{name_term.value}}"] } }
      expect(element).to receive(:render_output_of_join).with(value["join"])
      element.generate_field_val(value)
    end
  end

  describe '#value_with_substitutions' do
    it "replaces value when its the only thing in the string" do
      expect(element.value_with_substitutions("{{name_term.value}}")).to eql "Salinger, J. D."
    end

    it "replaces correct value when there are multiple references" do
      expect(element.value_with_substitutions("{{name_term.value}}{{name_term.uni}}")).to eql "Salinger, J. D.jds1329"
    end

    it "replaces corrext value when reference is surrounded by characters" do
      expect(element.value_with_substitutions("Author name is {{name_term.value}}.")).to eql "Author name is Salinger, J. D.."
    end
  end

  describe "#value_for_field_name" do
    it "looks up value when it starts with a $" do
      expect(element.value_for_field_name("$project.display_label")).to eql "Test Project"
    end

    it "returns data unavailable when referenced value doesn't have a matching variable" do
      expect(element.value_for_field_name("$project.expiration_date")).to eql "Data unavailable"
    end

    it "returns correct value when fields are nested" do
      expect(element.value_for_field_name("name_term.uni")).to eql "jds1329"
    end

    it "returns empty string if field does not exist" do
      expect(element.value_for_field_name("name_term.last_name")).to eql ""
    end

    context 'when value not nested' do
      let(:df_data) { dynamic_field_data["title"][0] }

      it "returns correct value" do
        expect(element.value_for_field_name("title_sort_portion")).to eql "Catcher in the Rye"
      end
    end
  end

  describe "#render_output_of_ternary" do
    it 'returns "true" value if field present' do
      arr = ["name_term.value", "Yes", "No"]
      expect(element.render_output_of_ternary(arr)).to eql "Yes"
    end

    it 'returns "false" value if field present' do
      arr = ["name_term.first_name", "Yes", "No"]
      expect(element.render_output_of_ternary(arr)).to eql "No"
    end

    it "renders field value if field present" do
      arr = ["name_term.value", "name_term.value", "No"]
      expect(element.render_output_of_ternary(arr)).to eql "name_term.value"
    end
  end

  describe "#render_output_of_join" do
    it "joins pieces with delimiter" do
      join_template = {
        "delimiter" => ", ",
        "pieces" => ["{{name_term.value}}", "{{name_term.uni}}", "{{name_term.uri}}"]
      }
      expect(element.render_output_of_join(join_template)).to eql "Salinger, J. D., jds1329, http://id.loc.gov/authorities/names/n50016589"
    end

    it "joins ternary pieces with delimiter" do
      join_template = {
        "delimiter" => ":",
        "pieces" => [
          { "ternary" => ["name_term.value", "{{name_term.value}}", ""] },
          { "ternary" => ["name_term.lastname", "{{name_term.lastname}}", "doe"] },
          "{{name_term.uni}}"
        ]
      }
      expect(element.render_output_of_join(join_template)).to eql "Salinger, J. D.:doe:jds1329"
    end

    it "removes blank values" do
      join_template = {
        "delimiter" => ", ",
        "pieces" => ['', '', '{{name_term.value}}']
      }
      expect(element.render_output_of_join(join_template)).to eql "Salinger, J. D."
    end
  end

  describe "#render?" do
    context 'when checking for multiple conditions' do
      let(:render_if) do
        {
          "present" => ["name_term.value", "name_term.uri"],
          "absent" => ["name_term.uni"]
        }
      end

      it 'return false when one is false' do
        expect(element.render?(render_if)).to be false
      end

      context 'when they are all true' do
        let(:df_data) { dynamic_field_data["name"][1] }

        it 'returns true' do
          expect(element.render?(render_if)).to be true
        end
      end
    end

    context 'when checking for fields that are present' do
      let(:df_data) { dynamic_field_data["title"][0] }

      it 'returns true if all fields are present' do
        render_if = { "present" => ["title_sort_portion", "title_non_sort_portion"] }
        expect(element.render?(render_if)).to be true
      end

      it "returns false if one field is missing" do
        render_if = { "present" => ["title_fake_field", "title_non_sort_portion"] }
        expect(element.render?(render_if)).to be false
      end
    end

    context "when checking for fields that are absent" do
      let(:df_data) { dynamic_field_data["title"][0] }

      it "returns true if all fields are absent" do
        render_if = { "absent" => ["title_fake_field", "title_fake_field_two"] }
        expect(element.render?(render_if)).to be true
      end

      it "returns false if one field is present" do
        render_if = { "absent" => ["title_fake_field", "title_non_sort_portion"] }
        expect(element.render?(render_if)).to be false
      end
    end

    context "when checking for fields that are equal" do
      it 'raises error when doing comparison with blank value' do
        render_if = { "equal" => { "name_term.uni" => ""} }
        expect{ element.render?(render_if) }.to raise_error ArgumentError
      end

      it "returns true if all fields eql given value" do
        render_if = { "equal" => { "name_term.uni" => "jds1329", "name_term.value" => "Salinger, J. D." } }
        expect(element.render?(render_if)).to be true
      end

      context 'when one field does not eql the given value' do
        let(:df_data) { dynamic_field_data["name"][1] }

        it "returns false" do
          render_if = { "equal" => { "name_term.uni" => "jds1329", "name_term.value" => "zzz" } }
          expect(element.render?(render_if)).to be false
        end
      end
    end

    context "when checking for fields that are not_equal" do
      it 'raises error when doing comparison with blank value' do
        render_if = { "not_equal" => { "name_term.uni" => ""} }
        expect{ element.render?(render_if) }.to raise_error ArgumentError
      end

      it "returns false when field equals value given" do
        render_if = { "not_equal" => { "name_term.uni" => "jds1329"} }
        expect(element.render?(render_if)).to be false
      end

      it "returns true when field does not equal single value given" do
        render_if = { "not_equal" => { "name_term.uni" => "zzz"} }
        expect(element.render?(render_if)).to be true
      end
    end

    context "when checking for fields that are equals_any_of" do
      it 'raises error when doing comparison with a non-array value' do
        render_if = { "equals_any_of" => { "name_term.uni" => ""} }
        expect{ element.render?(render_if) }.to raise_error ArgumentError
      end

      it 'raises error when doing comparison with an empty array value' do
        render_if = { "equals_any_of" => { "name_term.uni" => []} }
        expect{ element.render?(render_if) }.to raise_error ArgumentError
      end

      it "returns true when field equals any of the given array values" do
        render_if = { "equals_any_of" => { "name_term.uni" => ["zzz", "jds1329"], "name_term.value" => ["Salinger, J. D.", "zzz"] } }
        expect(element.render?(render_if)).to be true
      end

      context 'when one field does not eql any of the given array values for that field' do
        let(:df_data) { dynamic_field_data["name"][1] }

        it "returns false" do
          render_if = { "equals_any_of" => { "name_term.uni" => ["jds1329"], "name_term.value" => ["zzz"] } }
          expect(element.render?(render_if)).to be false
        end
      end
    end

    context "when checking for fields that are equals_none_of" do
      it 'raises error when doing comparison with a non-array value' do
        render_if = { "equals_none_of" => { "name_term.uni" => ""} }
        expect{ element.render?(render_if) }.to raise_error ArgumentError
      end

      it 'raises error when doing comparison with an empty array value' do
        render_if = { "equals_none_of" => { "name_term.uni" => []} }
        expect{ element.render?(render_if) }.to raise_error ArgumentError
      end

      it "returns false when field equals any of the array values given" do
        render_if = { "equals_none_of" => { "name_term.uni" => ["zzz", "jds1329"] } }
        expect(element.render?(render_if)).to be false
      end

      it "returns true when field equals none of array values given" do
        render_if = { "equals_none_of" => { "name_term.uni" => ["aaa", "bbb"]} }
        expect(element.render?(render_if)).to be true
      end
    end
  end
end
