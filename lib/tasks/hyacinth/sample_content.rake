# frozen_string_literal: true

namespace :hyacinth do
  namespace :sample_content do
    desc "Creates sample content (projects, publish targets, fields, sample record)"
    task create: :environment do
      Rake::Task['hyacinth:sample_content:create_projects'].invoke
      Rake::Task['hyacinth:sample_content:create_publish_targets'].invoke
      Rake::Task['hyacinth:sample_content:create_and_enable_fields'].invoke
      Rake::Task['hyacinth:sample_content:create_records'].invoke
      Rake::Task['hyacinth:sample_content:assign_sample_languages'].invoke
      Rake::Task['hyacinth:sample_content:assign_sample_strings'].invoke
    end

    task create_projects: :environment do
      project_configs = ['sample_project', 'other_sample_project'].map do |string_key|
        {
          string_key: string_key,
          display_label: string_key.titleize,
          has_asset_rights: true
        }
      end
      project_configs.each do |project_config|
        project_string_key = project_config[:string_key]
        if Project.exists?(string_key: project_string_key)
          puts Rainbow("Skipping creation of project #{project_string_key} because project already exists.").blue.bright
        else
          Project.create!(project_config)
          puts Rainbow("Created project: #{project_string_key}").green
        end
      end
    end

    task create_publish_targets: :environment do
      publish_target_configs = [1, 2].map do |salt|
        {
          string_key: "sample_publish_target_#{salt}",
          publish_url: "https://www.example.com/publish#{salt}",
          api_key: 'sample_api_key',
          is_allowed_doi_target: true
        }
      end
      publish_target_configs.each do |publish_target_config|
        publish_target_string_key = publish_target_config[:string_key]
        if PublishTarget.exists?(string_key: publish_target_string_key)
          puts Rainbow("Skipping creation of publish target #{publish_target_string_key} because publish target already exists.").blue.bright
        else
          new_publish_target = PublishTarget.create!(publish_target_config)
          sample_project.publish_targets << new_publish_target
          puts Rainbow("Created publish target: #{publish_target_string_key}").green
        end
      end
    end

    task create_and_enable_fields: :environment do
      Hyacinth::DynamicFieldsLoader.load_fields!(
        dynamic_field_categories: [{
          display_label: "Sample Field Category",
          metadata_form: 'descriptive',
          dynamic_field_groups: [
            {
              string_key: 'sample_field_group',
              display_label: 'Sample Field Group',
              is_repeatable: true,
              dynamic_fields: [
                { display_label: 'Sample Field', sort_order: 1, string_key: 'sample_field', field_type: DynamicField::Type::STRING },
                { display_label: 'Sample String', sort_order: 1, string_key: 'sample_string', field_type: DynamicField::Type::STRING, is_facetable: true, filter_label: 'Sample String' },
                { display_label: 'Sample Language', sort_order: 1, string_key: 'sample_lang', field_type: DynamicField::Type::LANG, is_facetable: true, filter_label: 'Sample Language' }
              ]
            },
            {
              string_key: 'other_sample_field_group',
              display_label: 'Other Sample Field Group',
              dynamic_fields: [
                { display_label: 'Other Sample Field', sort_order: 1, string_key: 'other_sample_field', field_type: DynamicField::Type::STRING }
              ]
            }
          ]
        }]
      )

      sample_project.tap do |project|
        [
          DynamicField.find_by_path_traversal(['sample_field_group', 'sample_field']),
          DynamicField.find_by_path_traversal(['other_sample_field_group', 'other_sample_field']),
          DynamicField.find_by_path_traversal(['sample_field_group', 'sample_string']),
          DynamicField.find_by_path_traversal(['sample_field_group', 'sample_lang'])
        ].each do |field|
          Hyacinth::Config.digital_object_types.keys.each do |digital_object_type|
            EnabledDynamicField.create!(project: project, dynamic_field: field, digital_object_type: digital_object_type)
          end
        end
      end
    end

    task create_records: :environment do
      sample_project.tap do |project|
        title_base = DigitalObject::Item.count + 1
        (ENV['NUM_ITEMS'] || 21).to_i.times do |i|
          item = DigitalObject::Item.new
          item.title = { 'value' => { 'sort_portion' => "Item #{i + title_base}" } }
          item.primary_project = project

          next if item.save

          puts  "\nErrors encountered during item save.\n"\
                "Digital Object creation requirements may have changed since this rake task was last updated.\n"\
                "Errors:\n" +
                item.errors.full_messages.inspect
          break
        end
      end
    end
    task load_sample_languages: :environment do
      lang_data = ENV.fetch('LANG_DATA', './spec/fixtures/files/iana_language/english-subtag-registry')
      Hyacinth::Language::SubtagLoader.new(lang_data).load
    end
    task assign_sample_languages: :load_sample_languages do
      langs = %w[
        cym cym-fonipa
        en en-US en-US-fonipa en-US-unifon
        en-CA en-CA-newfound en-CA-newfound-unifon en-CA-unifon
        en-GB en-GB-cornu en-GB-cornu-unifon en-GB-unifon
        en-IE en-IE-unifon en-IE-fonipa
        ga ga-fonipa
        gd gd-fonipa
        sco sco-fonipa sco-ulster sco-ulster-fonipa
      ]
      ctr = 0
      DigitalObject::Item.all.each do |item|
        item.primary_project ||= sample_project
        next unless item.primary_project.string_key == 'sample_project'
        tag = langs[ctr % langs.length]
        sample_field_group = item.descriptive_metadata['sample_field_group'] || [{}]
        sample_field_group << {} unless sample_field_group[1]
        sample_field_group.first['sample_lang'] = { 'tag' => tag }
        sample_field_group.second['sample_lang'] = { 'tag' => langs.sample }
        item.assign_descriptive_metadata('descriptive_metadata' => { 'sample_field_group' => sample_field_group })
        item.save!
        ctr += 1
      end
    end
    task assign_sample_strings: :environment do
      parts = [
        ['Greatest', 'Any', 'Worst', nil],
        ['Dog', 'Cat', 'Bird', nil],
        ['Doggerel', 'Caterwauling', 'Bird-watching', nil],
        ['Anywhere', 'Worldwide', 'West of Worst', nil]
      ]
      values = parts[0].product(*parts[1..3].to_a).map(&:compact).map{|x| x.join(' ') }.map(&:strip).shuffle
      ctr = 0
      DigitalObject::Item.all.each do |item|
        item.primary_project ||= sample_project
        next unless item.primary_project.string_key == 'sample_project'
        value = values[ctr % values.length]
        sample_field_group = item.descriptive_metadata['sample_field_group'] || [{}]
        sample_field_group << {} unless sample_field_group[1]
        sample_field_group.first['sample_string'] = value
        sample_field_group.second['sample_string'] = values.sample
        item.assign_descriptive_metadata('descriptive_metadata' => { 'sample_field_group' => sample_field_group })
        item.save!
        ctr += 1
      end
    end
    def sample_project
      Project.find_by(string_key: 'sample_project')
    end
  end
end
