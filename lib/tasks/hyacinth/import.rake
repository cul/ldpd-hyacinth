# frozen_string_literal: true
# rubocop:disable Metrics/BlockLength, Metrics/MethodLength
namespace :hyacinth do
  namespace :import do
    task hyacinth2: :environment do
      if ENV['PIDS'].present?
        pids = ENV['PIDS'].split(',')
      elsif ENV['PIDLIST'].present?
        pids = open(ENV['PIDLIST'], 'r').map(&:strip)
      else
        puts 'Error: Please supply a value for PIDS (one or more comma-separated Hyacinth PIDs) or PIDLIST (filepath)'
        next
      end
      def term_for_hash(atts)
        atts = atts.dup
        vocabulary = Vocabulary.find_by(string_key: atts.delete('vocabulary_string_key'))
        return nil unless vocabulary
        if atts['term_type'] == 'local'
          atts['uri'] = "#{Term.local_uri_prefix}term/#{atts['uri'].split('/')[-1]}"
        end
        term = Term.find_by(vocabulary: vocabulary, uri: atts['uri'])
        return term if term
        term = Term.new
        term.vocabulary = vocabulary
        term.pref_label = atts.delete('pref_label')
        term.term_type = atts.delete('term_type')
        if term.term_type == 'local'
          term.uid = atts.delete('uri').split('/')[-1]
        else
          term.uri = atts.delete('uri')
        end
        term.authority = atts.delete('authority')
        term.custom_fields = atts
        term.save!
        term
      end
      hyacinth2_client = Class.new(OpenStruct) {
        def json_url(pid)
          "#{url}/digital_objects/#{pid}.json"
        end

        def data_for(pid)
          json_uri = URI(json_url(pid))
          puts json_uri
          res = Net::HTTP.start(json_uri.host, json_uri.port, use_ssl: true) do |http|
            req = Net::HTTP::Get.new(json_uri)
            req['Authorization'] = "Basic #{Base64.strict_encode64(user + ':' + password)}"
            http.request(req)
          end
          if res.is_a?(Net::HTTPSuccess)
            JSON.parse(res.body)
          else
            puts "Fetch of #{pid} failed: #{res.message}"
            {}
          end
        end
      }.new(Rails.application.config_for(:secrets).dig(:accounts, :Hyacinth2))
      admin_user = User.find_by!(sort_name: 'User, Admin')
      pids.each do |pid|
        preservation_uri = "fedora3://#{pid}"
        hyacinth2_obj = hyacinth2_client.data_for(pid)
        puts JSON.pretty_generate(hyacinth2_obj)
        uid = hyacinth2_obj['uuid']
        # Find or create object and set system data
        if ::DigitalObject::Base.exists?(uid)
          digital_object = ::DigitalObject::Base.find(uid)
        else
          digital_object_type = hyacinth2_obj.dig('digital_object_type', 'string_key')
          case digital_object_type
          when 'item'
            digital_object = ::DigitalObject::Item.new
          else
            puts "No migration for digital object type #{digital_object_type}"
            next
          end
          digital_object.send(:uid=, uid)

          digital_object.send(:first_published_at=, ::DateTime.iso8601(hyacinth2_obj['first_published'])) if hyacinth2_obj['first_published']

          created_by_sort_name = hyacinth2_obj["created_by"].split(' ').map(&:strip).reverse.join(', ')
          digital_object.send(:created_by=, User.find_by(sort_name: created_by_sort_name) || admin_user)
          digital_object.send(:created_at=, ::DateTime.iso8601(hyacinth2_obj['created']))
          if hyacinth2_obj['modified']
            updated_by_sort_name = hyacinth2_obj["modified_by"].split(' ').map(&:strip).reverse.join(', ')
            digital_object.send(:updated_by=, User.find_by(sort_name: updated_by_sort_name) || admin_user)
            digital_object.send(:updated_at=, ::DateTime.iso8601(hyacinth2_obj['modified']))
          end
        end
        primary_project = Project.find_by!(string_key: hyacinth2_obj.dig('project', 'string_key'))
        digital_object.primary_project = primary_project
        actual_identifiers = hyacinth2_obj['identifiers'].reject { |value| [pid, uid].include?(value) }
        digital_object.identifiers.merge(actual_identifiers)
        if hyacinth2_obj['doi']
          doi_value = hyacinth2_obj['doi']
          doi_value.sub!("doi:", "")
          digital_object.send(:doi=, doi_value)
        end
        digital_object.preservation_target_uris << preservation_uri
        # Dynamic Field Data
        target_dfd = {}
        source_dfd = hyacinth2_obj['dynamic_field_data']
        # Dynamic Field Data: Title
        title = source_dfd.fetch('title', []).first
        if title
          target_dfd['title'] = [
            {
              'non_sort_portion' => title['title_non_sort_portion'],
              'sort_portion' => title['title_sort_portion']
            }
          ]
        end

        # Dynamic Field Data: Abstract
        abstract_values = source_dfd.fetch('abstract', []).map { |orig| { 'value' => orig['abstract_value'] } }
        target_dfd['abstract'] = abstract_values if abstract_values.present?

        # Dynamic Field Data: Names
        target_dfd['name'] = source_dfd.fetch("name", []).map do |old_value|
          new_value = { "term" => old_value['name_term'], "role" => old_value["name_role"] }
          new_value.compact!
          new_value["term"].tap do |term_hash|
            term_hash['term_type'] = term_hash.delete("type")
            term_hash['pref_label'] = term_hash.delete("value")
            term_hash.delete("internal_id")
          end
          new_value["term"] = JSON.load(term_for_hash(new_value["term"]).to_json)
          if new_value["role"].present?
            new_value["role"].map! do |role|
              term_hash = role.delete('name_role_term')
              term_hash['term_type'] = term_hash.delete("type")
              term_hash['pref_label'] = term_hash.delete("value")
              term_hash.delete("internal_id")
              role['term'] = JSON.load(term_for_hash(term_hash).to_json)
              role
            end
          end
          new_value
        end
        # Dynamic Field Data: Collections
        target_dfd['collection'] = source_dfd.fetch("collection", []).map do |old_value|
          new_value = { "term" => old_value['collection_term'] }
          new_value["term"].tap do |term_hash|
            term_hash['term_type'] = term_hash.delete("type")
            term_hash['pref_label'] = term_hash.delete("value")
            term_hash.delete("internal_id")
          end
          new_value["term"] = JSON.load(term_for_hash(new_value["term"]).to_json)
          new_value
        end
        # Dynamic Field Data: Date Created
        target_dfd['date_created'] = source_dfd.fetch('date_created', []).map do |old_value|
          new_value = {}
          new_value['start_value'] = old_value['date_created_start_value']
          new_value['key_date'] = old_value['date_created_key_date']
          new_value
        end
        target_dfd['date_created_textual'] = source_dfd.fetch('date_created_textual', []).map do |old_value|
          new_value = {}
          new_value['value'] = old_value['date_created_textual_value']
          new_value
        end
        # Dynamic Field Data: Language
        target_dfd['language'] = source_dfd.fetch('language', []).map do |old_value|
          new_value = { "term" => old_value['language_term'] }
          new_value["term"].tap do |term_hash|
            term_hash['term_type'] = term_hash.delete("type")
            term_hash['pref_label'] = term_hash.delete("value")
            term_hash.delete("internal_id")
          end
          new_value["term"] = JSON.load(term_for_hash(new_value["term"]).to_json)
          new_value
        end
        # Dynamic Field Data: Location
        target_dfd['location'] = source_dfd.fetch('location', []).map do |old_value|
          new_value = { "term" => old_value['location_term'] }
          new_value["term"].tap do |term_hash|
            term_hash['term_type'] = term_hash.delete("type")
            term_hash['pref_label'] = term_hash.delete("value")
            term_hash.delete("internal_id")
          end
          new_value["term"] = JSON.load(term_for_hash(new_value["term"]).to_json)
          new_value
        end
        digital_object.set_dynamic_field_data({ 'dynamic_field_data' => target_dfd }, false)
        digital_object.save
      end
    end
  end
end
