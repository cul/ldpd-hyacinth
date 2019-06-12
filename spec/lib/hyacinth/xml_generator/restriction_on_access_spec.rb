require 'rails_helper'

describe Hyacinth::XMLGenerator do
  let(:dynamic_field_data) do
    JSON.parse(fixture('lib/hyacinth/xml_generator/test_dynamic_field_data.json').read)
  end

  let(:restriction_on_access_logic) do
    '[
      {
        "render_if": {
          "not_equal": {
            "restriction_on_access_value" : "Closed"
          }
        },
        "element": "xacml:Rule",
        "attrs": {
            "RuleId": "{{$value_index}}",
            "Effect": "Permit"
        },
        "content": [
          {
            "element" : "xacml:Description",
            "content" : "{{restriction_on_access_value}}"
          },
          {
            "render_if": {
              "equal" : {
                "restriction_on_access_value" : "On-site Access"
              }
            },
            "element" : "xacml:Condition",
            "attrs" : {
              "FunctionId": "urn:oasis:names:tc:xacml:1.0:function:anyURI-at-least-one-member-of"
            },
            "content" : [
              {
                "element": "xacml:AttributeDesignator",
                "attrs": {
                  "MustBePresent":"false",
                  "Category":"urn:oasis:names:tc:xacml:3.0:attribute-category:environment",
                  "AttributeId":"urn:library.columbia.edu:names:reading-room-location",
                  "DataType":"http://www.w3.org/2001/XMLSchema#anyURI"
                }
              },
              {
                "element": "xacml:Apply",
                "attrs": {
                  "FunctionId":"urn:oasis:names:tc:xacml:1.0:function:anyURI-bag"
                },
                "content": {
                  "yield" : "restriction_on_access_location"
                }
              }
            ]
          },
          {
            "render_if": {
              "equal" : {
                "restriction_on_access_value" : "Specified Group/UNI Access"
              }
            },
            "element" : "xacml:Condition",
            "attrs" : {
              "FunctionId": "urn:oasis:names:tc:xacml:1.0:function:string-at-least-one-member-of"
            },
            "content" : [
              {
                "element": "xacml:AttributeDesignator",
                "attrs": {
                  "MustBePresent":"false",
                  "Category":"urn:oasis:names:tc:xacml:1.0:subject-category:access-subject",
                  "AttributeId":"http://www.ja-sig.org/products/cas/affiliation",
                  "DataType":"http://www.w3.org/2001/XMLSchema#string"
                }
              },
              {
                "element": "xacml:Apply",
                "attrs": {
                  "FunctionId":"urn:oasis:names:tc:xacml:1.0:function:string-bag"
                },
                "content": {
                  "yield" : "restriction_on_access_affiliation"
                }
              }
            ]
          }
        ]
      },
      {
        "render_if": {
          "equal": {
            "restriction_on_access_value" : "Closed"
          }
        },
        "element": "xacml:Rule",
        "attrs": {
            "RuleId": "{{$value_index}}",
            "Effect": "Deny"
        },
        "content": [
          {
            "element" : "xacml:Description",
            "content" : "{{restriction_on_access_value}}"
          }
        ]
      }
    ]'
  end

  let(:restriction_on_access_location_logic) do
    '[
      {
        "element": "xacml:AttributeValue",
        "attrs": {
          "DataType":"http://www.w3.org/2001/XMLSchema#anyURI",
          "FriendlyName":"{{restriction_on_access_location_term.value}}"
        },
        "content": "{{restriction_on_access_location_term.uri}}"
      }
    ]'
  end

  let(:restriction_on_access_affiliation_logic) do
    '[
      {
        "element": "xacml:AttributeValue",
        "attrs": {
          "DataType":"http://www.w3.org/2001/XMLSchema#string"
        },
        "content": "{{restriction_on_access_affiliation_value}}"
      }
    ]'
  end

  let(:xml_translation_map) do
    {
      'restriction_on_access' => restriction_on_access_logic,
      'restriction_on_access_location' => restriction_on_access_location_logic,
      'restriction_on_access_affiliation' => restriction_on_access_affiliation_logic
    }
  end

  let(:base_xml_translation) do
    JSON('
    {
      "element" : "xacml:Policy",
      "attrs" : {
        "xmlns:xacml" : "urn:oasis:names:tc:xacml:3.0:core:schema:wd-17",
        "xmlns:xsi" : "http://www.w3.org/2001/XMLSchema-instance",
        "PolicyId" : {
          "join" : {
            "delimiter" : ":",
            "pieces" : ["policy", "{{$uuid}}"]
          }
        },
        "RuleCombiningAlgId" : "urn:oasis:names:tc:xacml:3.0:rule-combining-algorithm:deny-unless-permit"
      },
      "content" : [
        {
          "element" : "xacml:Target",
          "content" : [
            {
              "element" : "xacml:AnyOf",
              "content" : [
                {
                  "element" : "xacml:AllOf",
                  "content" : [
                    {
                      "element" : "xacml:Match",
                      "attrs" : {
                        "MatchId" : "urn:oasis:names:tc:xacml:1.0:function:string-equal"
                      },
                      "content" : [
                        {
                          "element" : "xacml:AttributeValue",
                          "attrs" : {
                            "DataType" : "http://www.w3.org/2001/XMLSchema#string"
                          },
                          "content" : { "val" : "GET" }
                        },
                        {
                          "element" : "xacml:AttributeDesignator",
                          "attrs" : {
                            "MustBePresent" : "false",
                            "Category" : "urn:oasis:names:tc:xacml:3.0:attribute-category:action",
                            "AttributeId" : "urn:oasis:names:tc:xacml:1.0:action:action-id",
                            "DataType" : "http://www.w3.org/2001/XMLSchema#string"
                          }
                        }
                      ]
                    }
                  ]
                }
              ]
            }
          ]
        },
        {
          "yield" : "restriction_on_access"
        }
      ]
    }
    ')
  end

  let(:internal_fields) { {'uuid' => "89dcca6c-87b3-46d5-a1fd-1264ae7488c2"} }

  let(:xml_generator) do
    Hyacinth::XMLGenerator.new(dynamic_field_data, base_xml_translation, xml_translation_map, internal_fields)
  end

  describe '#generate' do
    context "generating authz XML" do
      let(:expected_xacml) { Nokogiri::XML(fixture('lib/hyacinth/xml_generator/stub.xml').read) }

      it 'generates corrext xml' do
        expect(xml_generator.generate).to be_equivalent_to expected_xacml
      end
      context "there are location-based restriction_on_access values" do
        let(:restriction_on_access_data) do
          JSON.parse(fixture('lib/hyacinth/xml_generator/test_restriction_on_access_location_data.json').read)
        end

        let(:dynamic_field_data) do
          JSON.parse(fixture('lib/hyacinth/xml_generator/test_dynamic_field_data.json').read).merge(restriction_on_access_data)
        end
        let(:expected_xacml) { Nokogiri::XML(fixture('lib/hyacinth/xml_generator/reading-room-restriction.xml').read) }

        it 'generates corrext xml' do
          expect(xml_generator.generate).to be_equivalent_to expected_xacml
        end
      end
      context "there are location-based restriction_on_access values" do
        let(:restriction_on_access_data) do
          JSON.parse(fixture('lib/hyacinth/xml_generator/test_restriction_on_access_affiliation_data.json').read)
        end

        let(:dynamic_field_data) do
          JSON.parse(fixture('lib/hyacinth/xml_generator/test_dynamic_field_data.json').read).merge(restriction_on_access_data)
        end
        let(:expected_xacml) { Nokogiri::XML(fixture('lib/hyacinth/xml_generator/group-restriction.xml').read) }

        it 'generates corrext xml' do
          expect(xml_generator.generate).to be_equivalent_to expected_xacml
        end
      end
      context "there are closed restriction_on_access values" do
        let(:restriction_on_access_data) do
          JSON.parse(fixture('lib/hyacinth/xml_generator/test_restriction_on_access_closed_data.json').read)
        end

        let(:dynamic_field_data) do
          JSON.parse(fixture('lib/hyacinth/xml_generator/test_dynamic_field_data.json').read).merge(restriction_on_access_data)
        end
        let(:expected_xacml) { Nokogiri::XML(fixture('lib/hyacinth/xml_generator/closed-restriction.xml').read) }

        it 'generates corrext xml' do
          expect(xml_generator.generate).to be_equivalent_to expected_xacml
        end
      end
    end
  end
end
