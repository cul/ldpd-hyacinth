# frozen_string_literal: true

require 'rails_helper'

describe Hyacinth::XmlGenerator do
  let(:descriptive_metadata) do
    JSON.parse(file_fixture('xml_generator/descriptive_metadata.json').read)
  end

  let(:name_translation_logic) do
    JSON('[
      {
        "render_if": {
          "present": ["term.value"]
        },
        "element": "mods:name",
        "attrs": {
          "type": "{{term.name_type}}",
          "ID": "{{term.uni}}",
          "usage": {
            "ternary": ["usage_primary", "primary", ""]
          },
          "valueURI": "{{term.uri}}",
          "authority": "{{term.authority}}"
        },
        "content": [
          {
            "element": "mods:namePart",
            "content": "{{term.value}}"
          },
          {
            "yield": "role"
          }
        ]
      }
    ]')
  end

  let(:role_translation_logic) do
    JSON('[
      {
        "render_if": {
          "present": [
              "term.value"
          ]
        },
        "element": "mods:role",
        "content": [
          {
            "element": "mods:roleTerm",
            "attrs": {
                "type": "text",
                "valueURI": "{{term.uri}}",
                "authority": "{{term.authority}}"
            },
            "content": "{{term.value}}"
          }
        ]
      }
    ]')
  end

  let(:xml_translation_map) do
    { 'name' => name_translation_logic, 'role' => role_translation_logic }
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
    described_class.new(descriptive_metadata, base_xml_translation, xml_translation_map)
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
        <mods:role>
          <mods:roleTerm type="text" valueURI="http://id.loc.gov/roles/456">Illustrator</mods:roleTerm>
        </mods:role>
        <mods:role>
          <mods:roleTerm type="text" valueURI="http://id.loc.gov/roles/789">Editor</mods:roleTerm>
        </mods:role>
     </mods:name>
    </mods:mods>'
  end

  describe '#generate' do
    context 'when nesting elements' do
      it 'generates correct xml' do
        expect(xml_generator.generate).to be_equivalent_to expected_mods
      end
    end

    context 'when render_if has multiple conditions' do
      let(:role_translation_logic) do # Should only render role for authors
        JSON('[
          {
            "render_if": {
              "present": [
                  "term.value"
              ],
              "equal": {
                "term.value": "Author"
              }
            },
            "element": "mods:role",
            "content": [
              {
                "element": "mods:roleTerm",
                "attrs": {
                    "type": "text",
                    "valueURI": "{{term.uri}}",
                    "authority": "{{term.authority}}"
                },
                "content": "{{term.value}}"
              }
            ]
          }
        ]')
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
        JSON('[
          {
            "render_if": {
              "present": ["term.value"]
            },
            "element": "mods:name",
            "attrs": {
              "type": "{{term.name_type}}",
              "ID": "{{term.uni}}",
              "usage": {
                "ternary": ["name_usage_primary", "primary", ""]
              },
              "valueURI": "{{term.uri}}",
              "authority": "{{term.authority}}"
            },
            "content": [
              {
                "element": "mods:namePart",
                "content": [{
                  "join": {
                    "delimiter": " - ",
                    "pieces": ["{{term.value}}", "{{term.uni}}"]
                  }
                }]
              }
            ]
          }
        ]')
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
        JSON('[
          {
            "render_if": {
              "present": ["term.value"]
            },
            "element": "mods:name",
            "attrs": {
              "type": "{{term.name_type}}",
              "ID": {
                "join": {
                  "delimiter": " ",
                  "pieces": ["{{term.uni}}", "{{term.value}}"]
                }
              },
              "valueURI": "{{term.uri}}",
              "authority": "{{term.authority}}"
            },
            "content": [
              {
                "element": "mods:namePart",
                "content": "{{term.value}}"
              }
            ]
          }
        ]')
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

    context "when content contains an array of strings" do
      let(:role_translation_logic) do
        JSON('[
          {
            "render_if": {
              "present": [
                  "term.value"
              ]
            },
            "element": "mods:role",
            "content": [
              {
                "element": "mods:roleTerm",
                "attrs": {
                    "type": "text",
                    "valueURI": "{{term.uri}}",
                    "authority": "{{term.authority}}"
                },
                "content": ["{{term.value}}"]
              }
            ]
          }
        ]')
      end

      it 'generates corrext xml' do
        expect(xml_generator.generate).to be_equivalent_to expected_mods
      end
    end
  end
end
