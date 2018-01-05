require 'rails_helper'

describe Hyacinth::XMLGenerator do
  let(:dynamic_field_data) do
    JSON.parse(fixture('lib/hyacinth/xml_generator/test_dynamic_field_data.json').read)
  end

  let(:name_translation_logic) do
    '[
      {
        "render_if": {
          "present": ["name_term.value"]
        },
        "element": "mods:name",
        "attrs": {
          "type": "{{name_term.name_type}}",
          "ID": "{{name_term.uni}}",
          "usage": {
            "ternary": ["name_usage_primary", "primary", ""]
          },
          "valueURI": "{{name_term.uri}}",
          "authority": "{{name_term.authority}}"
        },
        "content": [
          {
            "element": "mods:namePart",
            "content": "{{name_term.value}}"
          },
          {
            "yield": "name_role"
          }
        ]
      }
    ]'
  end

  let(:role_translation_logic) do
    '[
      {
        "render_if": {
          "present": [
              "name_role_term.value"
          ]
        },
        "element": "mods:role",
        "content": [
          {
            "element": "mods:roleTerm",
            "attrs": {
                "type": "text",
                "valueURI": "{{name_role_term.uri}}",
                "authority": "{{name_role_term.authority}}"
            },
            "content": "{{name_role_term.value}}"
          }
        ]
      }
    ]'
  end

  let(:xml_translation_map) do
    { 'name' => name_translation_logic, 'name_role' => role_translation_logic }
  end

  let(:base_xml_translation) do
    JSON('
      {
        "element": "mods:mods",
        "content": [
          {
            "yield": "name"
          }
        ]
      }
    ')
  end

  let(:xml_generator) do
    Hyacinth::XMLGenerator.new(dynamic_field_data, base_xml_translation, xml_translation_map)
  end

  describe '#generate' do
    context 'when nesting elements' do
      let(:expected_mods) do
        '<?xml version="1.0"?>
        <mods:mods>
          <mods:name ID="jds1329" valueURI="http://id.loc.gov/authorities/names/n50016589">
            <mods:namePart>Salinger, J. D.</mods:namePart>
            <mods:role>
              <mods:roleTerm type="text" valueURI="http://id.loc.gov/roles/123">Author</mods:roleTerm>
            </mods:role>
          </mods:name>
          <mods:name valueURI="http://id.loc.gov/authorities/names/n79006779">
            <mods:namePart>Lincoln, Abraham</mods:namePart>
            <mods:role>
              <mods:roleTerm type="text" valueURI="http://id.loc.gov/roles/456">Illustrator</mods:roleTerm>
            </mods:role>
            <mods:role>
              <mods:roleTerm type="text" valueURI="http://id.loc.gov/roles/789">Editor</mods:roleTerm>
            </mods:role>
         </mods:name>
        </mods:mods>'
      end

      it 'generates correct xml' do
        expect(xml_generator.generate).to be_equivalent_to expected_mods
      end
    end

    context 'when render_if has multiple conditions' do
      let(:role_translation_logic) do # Should only render role for authors
        '[
          {
            "render_if": {
              "present": [
                  "name_role_term.value"
              ],
              "equal": {
                "name_role_term.value": "Author"
              }
            },
            "element": "mods:role",
            "content": [
              {
                "element": "mods:roleTerm",
                "attrs": {
                    "type": "text",
                    "valueURI": "{{name_role_term.uri}}",
                    "authority": "{{name_role_term.authority}}"
                },
                "content": "{{name_role_term.value}}"
              }
            ]
          }
        ]'
      end

      let(:expected_mods) do
        '<?xml version="1.0"?>
        <mods:mods>
          <mods:name ID="jds1329" valueURI="http://id.loc.gov/authorities/names/n50016589">
            <mods:namePart>Salinger, J. D.</mods:namePart>
            <mods:role>
              <mods:roleTerm type="text" valueURI="http://id.loc.gov/roles/123">Author</mods:roleTerm>
            </mods:role>
          </mods:name>
          <mods:name valueURI="http://id.loc.gov/authorities/names/n79006779">
            <mods:namePart>Lincoln, Abraham</mods:namePart>
         </mods:name>
        </mods:mods>'
      end

      it 'generates corrext xml' do
        expect(xml_generator.generate).to be_equivalent_to expected_mods
      end
    end

    context 'when two fields are joined' do
      let(:name_translation_logic) do
        '[
          {
            "render_if": {
              "present": ["name_term.value"]
            },
            "element": "mods:name",
            "attrs": {
              "type": "{{name_term.name_type}}",
              "ID": "{{name_term.uni}}",
              "usage": {
                "ternary": ["name_usage_primary", "primary", ""]
              },
              "valueURI": "{{name_term.uri}}",
              "authority": "{{name_term.authority}}"
            },
            "content": [
              {
                "element": "mods:namePart",
                "content": [{
                  "join": {
                    "delimiter": " - ",
                    "pieces": ["{{name_term.value}}", "{{name_term.uni}}"]
                  }
                }]
              }
            ]
          }
        ]'
      end

      let(:expected_mods) do
        '<?xml version="1.0"?>
        <mods:mods>
          <mods:name ID="jds1329" valueURI="http://id.loc.gov/authorities/names/n50016589">
            <mods:namePart>Salinger, J. D. - jds1329</mods:namePart>
          </mods:name>
          <mods:name valueURI="http://id.loc.gov/authorities/names/n79006779">
            <mods:namePart>Lincoln, Abraham</mods:namePart>
         </mods:name>
        </mods:mods>'
      end

      it 'generates correct xml' do
        expect(xml_generator.generate).to be_equivalent_to expected_mods
      end
    end

    context "when joining in attribute values" do
      let(:name_translation_logic) do
        '[
          {
            "render_if": {
              "present": ["name_term.value"]
            },
            "element": "mods:name",
            "attrs": {
              "type": "{{name_term.name_type}}",
              "ID": {
                "join": {
                  "delimiter": " ",
                  "pieces": ["{{name_term.uni}}", "{{name_term.value}}"]
                }
              },
              "valueURI": "{{name_term.uri}}",
              "authority": "{{name_term.authority}}"
            },
            "content": [
              {
                "element": "mods:namePart",
                "content": "{{name_term.value}}"
              }
            ]
          }
        ]'
      end

      let(:expected_mods) do
        '<?xml version="1.0"?>
        <mods:mods>
          <mods:name ID="jds1329 Salinger, J. D." valueURI="http://id.loc.gov/authorities/names/n50016589">
            <mods:namePart>Salinger, J. D.</mods:namePart>
          </mods:name>
          <mods:name ID="Lincoln, Abraham" valueURI="http://id.loc.gov/authorities/names/n79006779">
            <mods:namePart>Lincoln, Abraham</mods:namePart>
         </mods:name>
        </mods:mods>'
      end

      it 'generates corrext xml' do
        expect(xml_generator.generate).to be_equivalent_to expected_mods
      end
    end
  end
end
