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
        atts.delete_if { |k, v| v.blank? } # delete stray custom fields
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
        primary_project = Project.find_by!(string_key: hyacinth2_obj.dig('project', 'string_key').downcase)
        digital_object.primary_project = primary_project
        actual_identifiers = hyacinth2_obj['identifiers'].reject { |value| [pid, uid].include?(value) }
        digital_object.identifiers.merge(actual_identifiers)
        if hyacinth2_obj['doi']
          doi_value = hyacinth2_obj['doi']
          doi_value.sub!("doi:", "")
          digital_object.send(:doi=, doi_value)
        end
        digital_object.preservation_target_uris << preservation_uri

        def deprefixed_field(source, fieldname, *subfields)
          results = source.fetch(fieldname, []).map do |source_value|
            target_value = source_value.deep_dup
            subfields.each { |subfield| target_value[subfield] = target_value.delete("#{fieldname}_#{subfield}") }
            target_value.delete_if { |k, v| v.blank? }
            yield(target_value) if block_given?
          end
          results
        end

        def simple_term_field(source, fieldname)
          results = source.fetch(fieldname, []).map do |source_value|
            target_value = source_value.deep_dup
            target_value["term"] = target_value.delete("#{fieldname}_term")
            target_value["term"].tap do |term_hash|
              term_hash['term_type'] = term_hash.delete("type")
              term_hash['pref_label'] = term_hash.delete("value")
              term_hash.delete("internal_id")
            end
            term_value = term_for_hash(target_value["term"])
            target_value["term"] = JSON.load(term_value.to_json)
            yield(target_value) if block_given?
          end
          results
        end

        # Dynamic Field Data
        target_dfd = {}
        source_dfd = hyacinth2_obj['dynamic_field_data']

        # Dynamic Field Data: Title
        target_dfd['title'] = deprefixed_field(source_dfd, 'non_sort_portion', 'sort_portion')

        # Dynamic Field Data: Abstract
        target_dfd['abstract'] = deprefixed_field(source_dfd, 'abstract', 'value')

        # Dynamic Field Data: Names
        target_dfd['name'] = simple_term_field(source_dfd, 'name') do |name_hash|
          name_hash['role'] = simple_term_field(name_hash, 'name_role')
          name_hash.delete('name_role')
          name_hash.delete('role') unless name_hash['role'].present?
        end
        # Dynamic Field Data: Collections
        target_dfd['collection'] = simple_term_field(source_dfd, 'collection')
        # Dynamic Field Data: Date Created
        target_dfd['date_created'] = deprefixed_field(source_dfd, 'date_created', 'start_value', 'end_value', 'key_date')
        target_dfd['date_created_textual'] = deprefixed_field(source_dfd, 'date_created_textual', 'value')

        # Dynamic Field Data: Language
        target_dfd['language'] = simple_term_field(source_dfd, 'language')
        # Dynamic Field Data: Location
        target_dfd['location'] = simple_term_field(source_dfd, 'location')
        # Dynamic Field Data: Form
        target_dfd['form'] = simple_term_field(source_dfd, 'form')
        # Dynamic Field Data: Genre
        target_dfd['genre'] = simple_term_field(source_dfd, 'genre')

        # Dynamic Field Data: Subjects
        target_dfd['subject_topic'] = simple_term_field(source_dfd, 'subject_topic')
        target_dfd['subject_geographic'] = simple_term_field(source_dfd, 'subject_geographic')
        target_dfd['subject_name'] = simple_term_field(source_dfd, 'subject_name')

        # Dynamic Field Data: Type of Resource
        target_dfd['type_of_resource'] = deprefixed_field(source_dfd, 'type_of_resource', 'value', 'is_collection')

        # Dynamic Field Data: Note
        target_dfd['note'] = deprefixed_field(source_dfd, 'note', 'value', 'type')

        # Dynamic Field Data: Internal Note
        target_dfd['internal_note'] = deprefixed_field(source_dfd, 'internal_note', 'value')

        # Dynamic Field Data: Alternative Title
        target_dfd['alternative_title'] = deprefixed_field(source_dfd, 'alternative_title', 'value')

        # Dynamic Field Data: Extent
        target_dfd['extent'] = deprefixed_field(source_dfd, 'extent', 'value')

        digital_object.set_dynamic_field_data({ 'dynamic_field_data' => target_dfd }, false)
        digital_object.save
      end
    end
  end
end
