FactoryBot.define do
  factory :field_export_profile do
    name { 'descMetadata' }
    translation_logic do
      '{
        "element": "mods:mods",
        "attrs": {
          "xmlns:xlink": "http://www.w3.org/1999/xlink",
          "version": "3.6",
          "xmlns:xsi": "http://www.w3.org/2001/XMLSchema-instance",
          "xmlns:mods": "http://www.loc.gov/mods/v3",
          "xsi:schemaLocation": "http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-6.xsd"
        },
        "content": [
          {
            "yield": "title"
          }
        ]
      }'
    end
  end
end
