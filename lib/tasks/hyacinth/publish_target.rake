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

    # Phase 1 - Assigning publish targets to projects
    # Usage: bundle exec rake hyacinth:publish_targets:assign_projects DRY_RUN=true
    desc 'Assign new publish targets to projects based on their legacy enabled publish targets'
    task assign_projects: :environment do
      # legacy_targets = parse_csv
      
      # Old digital object publish targets pids mapped to their new active record publish target string keys
      new_string_keys_by_legacy_pid = NEW_STRING_KEYS_BY_LEGACY_PT_PID
      # TODO: override legacy_targets with values from the hash above

      dry_run = ENV['DRY_RUN'] == 'true'
      puts 'Dry run: no changes will be saved.' if dry_run

      # Creates an hash of
      # Project => [legacy_enabled_publish_target_pid1, legacy_enabled_publish_target_pid2...]
      legacy_pids_by_project = Project.all.index_with do |project|
          puts "Project #{project.display_label} has these enabled publish targets #{project.enabled_publish_target_pids}"
         project.enabled_publish_target_pids.compact_blank
      end

      puts "========================"

      legacy_pids_by_project = legacy_pids_by_project.select { |_project, legacy_pids| legacy_pids.present? }

      unmapped_pids = legacy_pids_by_project.values.flatten.uniq - new_string_keys_by_legacy_pid.keys
      abort "No mapping for legacy publish targets: #{unmapped_pids.join(', ')}" if unmapped_pids.present?

      # Creates a hash of
      # Project => [new_publish_target_string_key1, new_publish_target_string_key2...]
      # Legacy publish targets mapped to nil don't add a new publish target
      new_string_keys_by_project = legacy_pids_by_project.transform_values do |legacy_pids|
        new_string_keys_by_legacy_pid.select { |legacy_pid, _string_key| legacy_pids.include?(legacy_pid) }.values.compact.uniq
      end

      publish_targets_by_string_key = PublishTarget.where(string_key: new_string_keys_by_project.values.flatten).index_by(&:string_key)
      puts "Publish targets by string key: #{publish_targets_by_string_key}"
      missing_string_keys = new_string_keys_by_project.values.flatten.uniq - publish_targets_by_string_key.keys
      abort "Publish targets don't exist: #{missing_string_keys.join(', ')}" if missing_string_keys.present?

      errors = []
      ActiveRecord::Base.transaction do
        new_string_keys_by_project.each do |project, string_keys|
          puts "Current project: #{project.string_key}"
          # Legacy publish targets that are mapped to nil
          unmapped_legacy_pids = legacy_pids_by_project[project].select { |legacy_pid| new_string_keys_by_legacy_pid[legacy_pid].nil? }
          puts "WARNING: #{project.string_key}: no new publish target for #{unmapped_legacy_pids.join(', ')}" if unmapped_legacy_pids.present?

          if string_keys.empty?
            puts "WARNING: #{project.string_key}: no new publish targets to assign"
            next
          end

          # Only add missing publish targets in case this task is run multiple times
          publish_targets = string_keys.map { |string_key| publish_targets_by_string_key[string_key] }
          new_publish_targets = publish_targets - project.publish_targets.to_a
          puts "#{project.string_key}: #{string_keys.join(', ')}#{' (already assigned)' if new_publish_targets.empty?}"

          
          next if dry_run || new_publish_targets.empty?
          
          puts "Project #{project.string_key} will be assigned the following publish targets #{new_publish_targets.inspect}"
  
          begin
            project.publish_targets << new_publish_targets
          rescue StandardError => e
            errors << "#{project.string_key}: #{e.message}"
          end
        end

        raise ActiveRecord::Rollback if errors.present?
      end

      abort "ERRORS: nothing was saved.\n#{errors.join("\n")}" if errors.present?
      puts dry_run ? 'Dry run complete: nothing was saved.' : 'Done.'
    end

    # Phase 2 - Assigning publish targets to digital object records
    # Usage: bundle exec rake hyacinth:publish_targets:assign_digital_objects DRY_RUN=true
    desc 'Assign new publish targets to digital objects'
    task assign_digital_objects: :environment do
      # TODO:
      # Perform this step based on the data exported from Solr
      # Skip objects of type "publish_target"
      # Use enabled_publish_target_pid_sim (no longer written after PT changes but present in prod)
    end
  end

end