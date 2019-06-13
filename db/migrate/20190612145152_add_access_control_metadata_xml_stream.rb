class AddAccessControlMetadataXmlStream < ActiveRecord::Migration
  def change
      puts 'Creating authorization XmlDatastream...'
      # Create XmlDatastreams
      XmlDatastream.create(string_key: 'accessControlMetadata', display_label: 'accessControlMetadata',
        xml_translation: {
      "render_if" => { "present" => ["restriction_on_access"] },
      "element" => "xacml:Policy",
      "attrs" => {
        "xmlns:xacml" => "urn:oasis:names:tc:xacml:3.0:core:schema:wd-17",
        "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
        "PolicyId" => "policy:{{$uuid}}",
        "RuleCombiningAlgId" => "urn:oasis:names:tc:xacml:3.0:rule-combining-algorithm:deny-unless-permit"
      },
      "content" => [
        {
          "element" => "xacml:Target",
          "content" => [
            {
              "element" => "xacml:AnyOf",
              "content" => [
                {
                  "element" => "xacml:AllOf",
                  "content" => [
                    {
                      "element" => "xacml:Match",
                      "attrs" => {
                        "MatchId" => "urn:oasis:names:tc:xacml:1.0:function:string-equal"
                      },
                      "content" => [
                        {
                          "element" => "xacml:AttributeValue",
                          "attrs" => {
                            "DataType" => "http://www.w3.org/2001/XMLSchema#string"
                          },
                          "content" => { "val" => "GET" }
                        },
                        {
                          "element" => "xacml:AttributeDesignator",
                          "attrs" => {
                            "MustBePresent" => "false",
                            "Category" => "urn:oasis:names:tc:xacml:3.0:attribute-category:action",
                            "AttributeId" => "urn:oasis:names:tc:xacml:1.0:action:action-id",
                            "DataType" => "http://www.w3.org/2001/XMLSchema#string"
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
          "yield" => "restriction_on_access"
        }
      ]
    }.to_json
      )
  end
end
