# frozen_string_literal: true

require 'rails_helper'

describe Hyacinth::XmlGenerator::FieldValues do
  let(:internal_fields) { { 'project.display_label' => 'Test Project' } }
  let(:xml_translation) { {} }
  let(:generator) { Hyacinth::XmlGenerator.new(nil, nil, nil, internal_fields) }

  let(:descriptive_metadata) do
    JSON.parse(file_fixture('xml_generator/descriptive_metadata.json').read)
  end

  let(:df_data) { descriptive_metadata["name"][0] }
  let(:values) { described_class.new(generator) }

  describe '#generate_field_val' do
    it 'returns string' do
      expect(values.generate_field_val("foobar", df_data)).to eql 'foobar'
    end

    it 'returns val' do
      expect(values.generate_field_val({ "val" => "foobar" }, df_data)).to eql 'foobar'
    end

    it 'returns calculated ternary result' do
      value = { "ternary" => ["term.value", "term.value", ""] }
      expect(values).to receive(:render_output_of_ternary).with(value["ternary"], df_data)
      values.generate_field_val(value, df_data)
    end

    it 'returns joined string' do
      value = { "join" => { "delimiter" => ",", "pieces" => ["{{term.value}}"] } }
      expect(values).to receive(:render_output_of_join).with(value["join"], df_data)
      values.generate_field_val(value, df_data)
    end
  end

  describe '#value_with_substitutions' do
    it "replaces value when its the only thing in the string" do
      expect(values.value_with_substitutions("{{term.value}}", df_data)).to eql "Salinger, J. D."
    end

    it "replaces correct value when there are multiple references" do
      expect(values.value_with_substitutions("{{term.value}}{{term.uni}}", df_data)).to eql "Salinger, J. D.jds1329"
    end

    it "replaces corrext value when reference is surrounded by characters" do
      expect(values.value_with_substitutions("Author name is {{term.value}}.", df_data)).to eql "Author name is Salinger, J. D.."
    end
  end

  describe "#value_for_field_name" do
    it "looks up value when it starts with a $" do
      expect(values.value_for_field_name("$project.display_label", df_data)).to eql "Test Project"
    end

    it "returns data unavailable when referenced value doesn't have a matching variable" do
      expect(values.value_for_field_name("$project.expiration_date", df_data)).to eql "Data unavailable"
    end

    it "returns correct value when fields are nested" do
      expect(values.value_for_field_name("term.uni", df_data)).to eql "jds1329"
    end

    it "returns empty string if field does not exist" do
      expect(values.value_for_field_name("term.last_name", df_data)).to eql ""
    end

    context 'when value not nested' do
      let(:df_data) { descriptive_metadata["title"][0] }

      it "returns correct value" do
        expect(values.value_for_field_name("sort_portion", df_data)).to eql "Catcher in the Rye"
      end
    end
  end

  describe "#render_output_of_ternary" do
    it 'returns "true" value if field present' do
      arr = ["term.value", "Yes", "No"]
      expect(values.render_output_of_ternary(arr, df_data)).to eql "Yes"
    end

    it 'returns "false" value if field present' do
      arr = ["term.first_name", "Yes", "No"]
      expect(values.render_output_of_ternary(arr, df_data)).to eql "No"
    end

    it "renders field value if field present" do
      arr = ["term.value", "term.value", "No"]
      expect(values.render_output_of_ternary(arr, df_data)).to eql "term.value"
    end
  end

  describe "#render_output_of_join" do
    it "joins pieces with delimiter" do
      join_template = {
        "delimiter" => ", ",
        "pieces" => ["{{term.value}}", "{{term.uni}}", "{{term.uri}}"]
      }
      expect(values.render_output_of_join(join_template, df_data)).to eql "Salinger, J. D., jds1329, http://id.loc.gov/authorities/names/n50016589"
    end

    it "joins ternary pieces with delimiter" do
      join_template = {
        "delimiter" => ":",
        "pieces" => [
          { "ternary" => ["term.value", "{{term.value}}", ""] },
          { "ternary" => ["term.lastname", "{{term.lastname}}", "doe"] },
          "{{term.uni}}"
        ]
      }
      expect(values.render_output_of_join(join_template, df_data)).to eql "Salinger, J. D.:doe:jds1329"
    end

    it "removes blank values" do
      join_template = {
        "delimiter" => ", ",
        "pieces" => ['', '', '{{term.value}}']
      }
      expect(values.render_output_of_join(join_template, df_data)).to eql "Salinger, J. D."
    end
  end
end
