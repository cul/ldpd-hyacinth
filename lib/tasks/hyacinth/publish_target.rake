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
      # Perform this step based on the data exported from Solr
      # Use enabled_publish_target_pid_sim (no longer written after PT changes but present in prod)
      # Only writes to the digital_object_records_publish_targets table. Fedora isn't read or modified.

      # The CSV below includes the following Digital Object fields:
      # pid
      # state_ss (useful for reporting)
      # hyacinth_type_ss (items vs assets; useful for reporting)
      # project_string_key_sim (can have multiple values, joined with a comma)
      # enabled_publish_target_pid_sim (can have multiple values, joined with a comma)
      csv_path = File.join(Rails.root, 'tmp', 'digital_objects-20261120.csv')

      # Old digital object publish targets pids mapped to their new active record publish target string keys
      new_string_keys_by_legacy_pid = NEW_STRING_KEYS_BY_LEGACY_PT_PID_FOR_DIGITAL_OBJECTS

      dry_run = ENV['DRY_RUN'] == 'true'
      puts 'Dry run: no changes will be saved.' if dry_run

      publish_targets_by_string_key = PublishTarget.all.index_by(&:string_key)
      puts "Publish targets by string key: #{publish_targets_by_string_key}"
      missing_string_keys = new_string_keys_by_legacy_pid.values.compact.uniq - publish_targets_by_string_key.keys
      abort "Publish targets don't exist: #{missing_string_keys.join(', ')}" if missing_string_keys.present?

      # Project string key => [publish target string keys enabled for the project]
      publish_target_string_keys_by_project = {}
      Project.includes(:publish_targets).each do |project|
        publish_target_string_keys_by_project[project.string_key] = project.publish_targets.map(&:string_key)
      end

      updated_count = 0
      error_count = 0

      CSV.open(csv_path, 'rb', headers: true) do |csv|
        csv.each do |row|
          pid = row['pid']
          project_string_keys = row['project_string_key_sim'].to_s.split(',').map(&:strip)
          legacy_pids = row['enabled_publish_target_pid_sim'].to_s.split(',').map(&:strip)

          # These should already be excluded but flag if they're present
          if row['hyacinth_type_ss'] == 'publish_target' || row['state_ss'] == 'D'
            puts "#{pid}: skipped (type: #{row['hyacinth_type_ss']}, state: #{row['state_ss']})"
            next
          end

          record = DigitalObjectRecord.find_by(pid: pid)
          if record.nil?
            puts "ERROR: #{pid}: digital object record not found"
            error_count += 1
            next
          end

          string_keys = []

          # Map to the new publish targets that rely on string keys instead
          legacy_pids.each do |legacy_pid|
            if new_string_keys_by_legacy_pid[legacy_pid].present?
              puts "Mapping old pid: #{legacy_pid} to #{new_string_keys_by_legacy_pid[legacy_pid]}"
              string_keys << new_string_keys_by_legacy_pid[legacy_pid]
            elsif new_string_keys_by_legacy_pid.key?(legacy_pid)
              puts "WARNING: #{pid}: legacy publish target #{legacy_pid} isn't mapped yet"
            elsif !NEW_STRING_KEYS_BY_LEGACY_PT_PID.key?(legacy_pid)
              puts "ERROR: #{pid}: unknown legacy publish target #{legacy_pid}"
              error_count += 1
            end
            # Anything else is a subsite and doesn't need a mapping
          end

          string_keys = string_keys.uniq
          puts "New publish target string keys: #{string_keys} for document #{pid}"

          if string_keys.empty?
            puts "WARNING: #{pid}: no new publish targets to assign (legacy publish targets: #{legacy_pids.join(', ')})"
            next
          end

          # Publish targets need to be assigned to the project the digital object uses. Otherwise, the object can't be saved.
          project_publish_target_string_keys = []
          project_string_keys.each do |project_string_key|
            if publish_target_string_keys_by_project.key?(project_string_key)
              project_publish_target_string_keys += publish_target_string_keys_by_project[project_string_key]
            else
              puts "WARNING: #{pid}: project #{project_string_key} not found"
            end
          end
          not_enabled_string_keys = string_keys - project_publish_target_string_keys
          puts "WARNING: #{pid}: #{not_enabled_string_keys.join(', ')} not enabled for project #{project_string_keys.join(', ')}" if not_enabled_string_keys.present?

          # Only add missing publish targets in case this task is run multiple times
          publish_targets = string_keys.map { |string_key| publish_targets_by_string_key[string_key] }
          new_publish_targets = publish_targets - record.publish_targets.to_a
          puts "#{pid}: #{string_keys.join(', ')}#{' (already assigned)' if new_publish_targets.empty?}"

          next if dry_run || new_publish_targets.empty?

          begin
            record.publish_targets << new_publish_targets
            updated_count += 1
          rescue StandardError => e
            puts "ERROR: #{pid}: #{e.message}"
            error_count += 1
          end
        end
      end

      puts dry_run ? 'Dry run complete: nothing was saved.' : "Done. Updated #{updated_count} digital object records."
      puts "#{error_count} errors" if error_count.positive?
    end
  end

end