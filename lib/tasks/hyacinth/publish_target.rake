require_relative "publish_targets_pids_to_string_key"

namespace :hyacinth do

  namespace :publish_targets do
    # Parses a CSV containing legacy publish targets
    def parse_csv
      targets_mapped = {}

      legacy_targets =  "#{Rails.root}/tmp/export-3611-20261113_174913.csv"
      csv = CSV.open(legacy_targets, 'rb', headers: true) do |csv|
        csv.each do |row|
          pid = row['_pid']
          title = row['title-1:title_sort_portion']
          targets_mapped[pid] = title
        end
      end

      puts targets_mapped
      return targets_mapped
    end

    # Usage: bundle exec rake hyacinth:publish_targets:assign_projects DRY_RUN=true
    desc 'Assign new publish targets to projects based on their legacy enabled publish targets'
    task assign_projects: :environment do
      # legacy_targets = parse_csv
      
      # Old digital object publish targets pids mapped to their new active record publish target string keys
      new_string_keys_by_legacy_pid = NEW_STRING_KEYS_BY_LEGACY_PT_PID
      # TODO: override legacy_targets with values from the hash above
  
      # Staging projects only get DLC Catalog Staging (to confirm)
      # TODO: Replace with the string keys of these projects:
      # DLC Catalog [Staging], DLC Restricted Catalog [Staging], Carnegie Corporation Oral History Project [Staging],
      # Language and Culture Archive of Ashkenazic Jewry [Staging], Sites Restricted [Staging], Sites [Staging],
      # The New York real estate brochure collection [staging], Time Based Media [Staging]
      staging_project_string_keys = ['legacy_dlc_staging']
      dry_run = ENV['DRY_RUN'] == 'true'
      puts 'Dry run: no changes will be saved.' if dry_run

      # Creates an hash of
      # Project => [legacy_enabled_publish_target_pid1, legacy_enabled_publish_target_pid2...]
      legacy_pids_by_project = Project.all.index_with do |project|
          puts "Project #{project.display_label} has these enabled publish targets #{project.enabled_publish_target_pids}"
         project.enabled_publish_target_pids.compact_blank
      end

      puts "========================"

      puts "Legacy pids by project: #{legacy_pids_by_project}"
      legacy_pids_by_project = legacy_pids_by_project.select { |_project, legacy_pids| legacy_pids.present? }
      puts "========================"
      puts "Legacy pids updated: #{legacy_pids_by_project.inspect}"

      unmapped_pids = legacy_pids_by_project.values.flatten.uniq - new_string_keys_by_legacy_pid.keys
      abort "No mapping for legacy publish targets: #{unmapped_pids.join(', ')}" if unmapped_pids.present?

      # return
      new_string_keys_by_project = legacy_pids_by_project.to_h do |project, legacy_pids|
        # An array of publish targets string keys that should be enabled for the project
        string_keys = new_string_keys_by_legacy_pid.select { |legacy_pid, string_key| legacy_pids.include?(legacy_pid)}.values

        # Staging projects use the staging instance of DLC Catalog
        string_keys = string_keys.map { |key| key == 'dlc_catalog' ? 'dlc_catalog_staging' : key } if staging_project_string_keys.include?(project.string_key)
        [project, string_keys.uniq]
      end

      publish_targets_by_string_key = PublishTarget.where(string_key: new_string_keys_by_project.values.flatten).index_by(&:string_key)
      missing_string_keys = new_string_keys_by_project.values.flatten.uniq - publish_targets_by_string_key.keys
      abort "Publish targets don't exist: #{missing_string_keys.join(', ')}" if missing_string_keys.present?

      # ActiveRecord::Base.transaction do
      #   new_string_keys_by_project.each do |project, string_keys|
      #   end
      # end
    end
  end

end