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
                      "$title.value_lang.tag"
                    ]
                  },
                  "val": "{{$title.value_lang.tag}}"
                },
                "lang": {
                  "render_if": {
                    "present": [
                      "$title.value_lang.lang"
                    ]
                  },
                  "val": "{{$title.value_lang.lang}}"
                },
                "script": {
                  "render_if": {
                    "present": [
                      "$title.value_lang.script"
                    ]
                  },
                  "val": "{{$title.value_lang.script}}"
                }
              },
              "content": [
                {
                  "element": "mods:nonSort",
                  "render_if": {
                    "present": [
                      "$title.value.non_sort_portion"
                    ]
                  },
                  "content": "{{$title.value.non_sort_portion}}"
                },
                {
                  "element": "mods:title",
                  "content": "{{$title.value.sort_portion}}"
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
