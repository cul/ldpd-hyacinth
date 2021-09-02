# frozen_string_literal: true

FactoryBot.define do
  factory :export_rule do
    association :field_export_profile
    association :dynamic_field_group

    translation_logic do
      '[
         {
           "render_if": {
             "present": ["role"]
           },
           "element": "mods:name",
           "content": "{{role}}"
         }
      ]'
    end
    trait :for_alternative_title_field do
      translation_logic do
        '[
          {
            "render_if": {
              "present": [
                "value"
              ]
            },
            "element": "mods:titleInfo",
            "attrs": {
              "type": "alternative",
              "xml:lang": {
                "render_if": {
                  "present": [
                    "value_lang.tag"
                  ]
                },
                "val": "{{value_lang.tag}}"
              },
              "lang": {
                "render_if": {
                  "present": [
                    "value_lang.lang"
                  ]
                },
                "val": "{{value_lang.lang}}"
              },
              "script": {
                "render_if": {
                  "present": [
                    "value_lang.script"
                  ]
                },
                "val": "{{value_lang.script}}"
              }
            },
            "content": [
              {
                "element": "mods:title",
                "content": "{{value}}"
              }
            ]
          }
        ]'
      end
    end
  end
end
