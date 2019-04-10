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
  end
end
