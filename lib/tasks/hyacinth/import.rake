# frozen_string_literal: true
# rubocop:disable Metrics/BlockLength, Metrics/MethodLength, Metrics/AbcSize
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
        vocabulary_string_key = atts.delete('vocabulary_string_key')
        vocabulary = Vocabulary.find_by(string_key: vocabulary_string_key)
        unless vocabulary
          puts "could not find Vocabulary.string_key == '#{vocabulary_string_key}'"
          return nil
        end

        atts['uri'] = "#{Term.local_uri_prefix}term/#{atts['uri'].split('/')[-1]}" if atts['term_type'] == 'local'
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
        atts.delete_if { |_k, v| v.blank? } # delete stray custom fields
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
        uid = hyacinth2_obj['uuid']
        puts "#{uid}\t#{preservation_uri}"
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

          created_by_sort_name = (hyacinth2_obj["created_by"] || "Admin User").split(' ').map(&:strip).reverse.join(', ')
          digital_object.send(:created_by=, User.find_by(sort_name: created_by_sort_name) || admin_user)
          digital_object.send(:created_at=, ::DateTime.iso8601(hyacinth2_obj['created']))
          if hyacinth2_obj['modified']
            updated_by_sort_name = (hyacinth2_obj["modified_by"] || "Admin User").split(' ').map(&:strip).reverse.join(', ')
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
            target_value.delete_if { |_k, v| v.blank? }
            yield(target_value) if block_given?
            target_value
          end
          results
        end

        def simple_term_field(source, fieldname)
          results = source.fetch(fieldname, []).map do |source_value|
            target_value = source_value.deep_dup
            target_value["term"] = target_value.delete("#{fieldname}_term")
            if target_value["term"] # some groups have mixed content
              target_value["term"].tap do |term_hash|
                term_hash['term_type'] = term_hash.delete("type")
                term_hash['pref_label'] = term_hash.delete("value")
                term_hash.delete("internal_id")
              end
              term_value = term_for_hash(target_value["term"])
              target_value["term"] = JSON.parse(term_value.to_json)
            end
            yield(target_value) if block_given?
            target_value
          end
          results
        end

        # Dynamic Field Data
        target_dfd = {}
        source_dfd = hyacinth2_obj['dynamic_field_data']

        # Dynamic Field Data: Title
        target_dfd['title'] = deprefixed_field(source_dfd, 'title', 'non_sort_portion', 'sort_portion')

        # Dynamic Field Data: Abstract
        target_dfd['abstract'] = deprefixed_field(source_dfd, 'abstract', 'value')

        # Dynamic Field Data: Names
        target_dfd['name'] = simple_term_field(source_dfd, 'name') do |name_hash|
          name_hash['role'] = simple_term_field(name_hash, 'name_role')
          name_hash.delete('name_role')
          name_hash.delete('role') unless name_hash['role'].present?
        end
        # Dynamic Field Data: Collections
        target_dfd['collection'] = simple_term_field(source_dfd, 'collection') do |collection_hash|
          collection_hash['archival_series'] = deprefixed_field(collection_hash, 'collection_archival_series', 'part') do |archival_series_hash|
            archival_series_hash['part'] && archival_series_hash['part'].each do |part_hash|
              deep_nests = ['level', 'title', 'type']
              deep_nests.each { |deep_nest| part_hash[deep_nest] = part_hash.delete("collection_archival_series_part_#{deep_nest}") }
              part_hash.compact!
            end
          end
          collection_hash.delete('collection_archival_series')
        end
        # Dynamic Field Data: Dates
        target_dfd['date_created'] = deprefixed_field(source_dfd, 'date_created', 'start_value', 'end_value', 'key_date', 'type')
        target_dfd['date_created_textual'] = deprefixed_field(source_dfd, 'date_created_textual', 'value')
        target_dfd['date_issued'] = deprefixed_field(source_dfd, 'date_issued', 'start_value', 'end_value', 'key_date', 'type')
        target_dfd['date_issued_textual'] = deprefixed_field(source_dfd, 'date_issued_textual', 'value')

        # Dynamic Field Data: Language
        target_dfd['language'] = simple_term_field(source_dfd, 'language')
        # Dynamic Field Data: Location
        target_dfd['location'] = simple_term_field(source_dfd, 'location') do |location_hash|
          location_hash['shelf_location'] = deprefixed_field(location_hash, 'location_shelf_location', 'box_number', 'call_number', 'folder_number', 'item_number', 'free_text')
          location_hash.delete('location_shelf_location')
        end

        # Dynamic Field Data: Physical Information
        target_dfd['form'] = simple_term_field(source_dfd, 'form')
        target_dfd['extent'] = deprefixed_field(source_dfd, 'extent', 'value')
        target_dfd['digital_origin'] = deprefixed_field(source_dfd, 'digital_origin', 'value')

        # Dynamic Field Data: Publisher
        target_dfd['publisher'] = deprefixed_field(source_dfd, 'publisher', 'value')

        # Dynamic Field Data: Genre
        target_dfd['genre'] = simple_term_field(source_dfd, 'genre')

        # Dynamic Field Data: Subjects
        target_dfd['subject_topic'] = simple_term_field(source_dfd, 'subject_topic')
        target_dfd['subject_geographic'] = simple_term_field(source_dfd, 'subject_geographic')
        target_dfd['subject_name'] = simple_term_field(source_dfd, 'subject_name')
        target_dfd['subject_title'] = simple_term_field(source_dfd, 'subject_title')
        target_dfd['culture'] = simple_term_field(source_dfd, 'culture')

        # Dynamic Field Data: Type of Resource
        target_dfd['type_of_resource'] = deprefixed_field(source_dfd, 'type_of_resource', 'value', 'is_collection')

        # Dynamic Field Data: Notes
        target_dfd['note'] = deprefixed_field(source_dfd, 'note', 'value', 'type')
        target_dfd['internal_note'] = deprefixed_field(source_dfd, 'internal_note', 'value')

        # Dynamic Field Data: Alternative Title
        target_dfd['alternative_title'] = deprefixed_field(source_dfd, 'alternative_title', 'value')

        # Dynamic Field Data: Place of Origin
        target_dfd['place_of_origin'] = deprefixed_field(source_dfd, 'place_of_origin', 'value')

        # Dynamic Field Data: Identifiers
        target_dfd['accession_number'] = deprefixed_field(source_dfd, 'accession_number', 'value')
        target_dfd['clio_identifier'] = deprefixed_field(source_dfd, 'clio_identifier', 'value')
        target_dfd['clio_identifier'].delete_if do |id_hash|
          target_dfd['collection'].detect { |collection| id_hash['value'] && id_hash['value'] == collection.dig('term', 'clio_id') }
        end

        # Dynamic Field Data: Customer Order Information
        target_dfd['order_date'] = deprefixed_field(source_dfd, 'order_date', 'value')
        target_dfd['order_number'] = deprefixed_field(source_dfd, 'order_number', 'value')

        # Dynamic Field Data: Record Information
        target_dfd['record_content_source'] = deprefixed_field(source_dfd, 'record_content_source', 'value')

        rights_data = {}
        # Rights Data: Copyright Status (Term from use_and_reproduction)
        copyright_value = simple_term_field(source_dfd, 'use_and_reproduction')
        copyright_note = copyright_value.map { |value_hash| value_hash.delete('use_and_reproduction_value') }
        copyright_note.compact!
        if copyright_value.present? || copyright_note.present?
          copyright_status = {
            'copyright_statement' => copyright_value.first&.fetch('term'),
            'note' => copyright_note.join("\n")
          }
          copyright_status.compact!
          rights_data['copyright_status'] = [copyright_status]
        end

        # Rights Data: Copyright Owner Name (Term)
        copyright_owner = simple_term_field(source_dfd, 'copyright_owner')
        rights_data['copyright_ownership'] = copyright_owner.map { |term| { 'name' => term['term'] } } if copyright_owner.present?

        digital_object.set_dynamic_field_data({ 'dynamic_field_data' => target_dfd }, false)
        digital_object.set_rights('rights' => rights_data)
        digital_object.save
      end
    end
  end
end
