# frozen_string_literal: true

FactoryBot.define do
  factory :field_export_profile do
    name { 'descMetadata' }
    translation_logic do
      '{
        "element": "mods:mods",
        "content": [
          {
            "yield": "name"
          }
        ]
      }'
    end
    trait :for_title_attribute do
      translation_logic do
        '{
          "element": "mods:mods",
          "attrs": {
            "xmlns:mods": "http://example.org/"
          },
          "content": [
            {
              "render_if": {
                "present": [
                  "$title"
                ]
              },
              "element": "mods:titleInfo",
              "attrs": {
                "xml:lang": {
                  "render_if": {
                    "present": [
                      "$title.xml_lang"
                    ]
                  },
                  "val": "{{$title.xml_lang}}"
                },
                "lang": {
                  "render_if": {
                    "present": [
                      "$title.lang"
                    ]
                  },
                  "val": "{{$title.lang}}"
                },
                "script": {
                  "render_if": {
                    "present": [
                      "$title.script"
                    ]
                  },
                  "val": "{{$title.script}}"
                }
              },
              "content": [
                {
                  "element": "mods:nonSort",
                  "render_if": {
                    "present": [
                      "$title.non_sort_portion"
                    ]
                  },
                  "content": "{{$title.non_sort_portion}}"
                },
                {
                  "element": "mods:title",
                  "content": "{{$title.sort_portion}}"
                },
                {
                  "element": "mods:subTitle",
                  "render_if": {
                    "present": [
                      "$title.subtitle"
                    ]
                  },
                  "content": "{{$title.subtitle}}"
                }
              ]
            }
          ]
        }'
      end
    end
  end
end
