# frozen_string_literal: true

module DigitalObjectConcerns
  module CreateAndUpdateTerms
    extend ActiveSupport::Concern

    private

      # For all the terms in the :rights and :descriptive_metadata fields, creates the terms if they
      # don't already exist. If the terms already exists updates the term with any new field data. Only
      # term fields that don't have data will be updated. Errors will be raised instead of placed in the
      # errors array.
      def create_and_update_terms
        # Extract for rights and descriptive_metadata. If digital object is not of the appropriate type
        # do not extract rights terms.
        rights_terms = can_have_rights? ? Hyacinth::DynamicFieldsMap.new("#{digital_object_type}_rights").extract_terms(rights) : {}

        descriptive_terms = Hyacinth::DynamicFieldsMap.new('descriptive').extract_terms(descriptive_metadata)

        extracted_terms = rights_terms.merge(descriptive_terms) { |_key, oldval, newval| oldval.concat(newval) }

        solr_results = search_for_terms(extracted_terms)

        # Retrive all vocabularies that are referenced with their database id and custom fields
        vocabularies = Vocabulary.where(string_key: extracted_terms.keys)
                                 .map { |v| [v.string_key, { id: v.id, custom_fields: v.custom_fields }] }
                                 .to_h

        # Go through all terms and create or update as necessary.
        extracted_terms.each do |vocabulary, terms|
          vocabulary_id = vocabularies[vocabulary][:id]
          valid_custom_field_keys = vocabularies[vocabulary][:custom_fields].keys

          terms.each do |term|
            uri = term.key?('uri') ? term['uri'] : Term.temporary_uri(vocabulary, term['pref_label'])

            found_term = solr_results.find { |t| t['uri'] == uri && t['vocabulary'] == vocabulary }

            if found_term
              found_term = Hyacinth::DynamicFieldDataHelper.format_term(found_term, valid_custom_field_keys)

              # Check if any of values in term are nil in found_term. For arrays, need to check that the value is blank?
              update_args = term.select do |f, v|
                if f == 'alt_labels'
                  !v.empty? && found_term[f].empty?
                else
                  !v.nil? && found_term[f].nil?
                end
              end

              if update_args.present?
                lookup_args = { vocabulary_id: vocabulary_id, uri: uri }
                rehydrate_with = update_term(lookup_args, update_args, valid_custom_field_keys)
              else
                rehydrate_with = found_term
              end
            else
              rehydrate_with = create_term(term, vocabulary_id, valid_custom_field_keys)
            end

            # Rehydrate term hash
            Hyacinth::DynamicFieldDataHelper.rehydrate_term(term, rehydrate_with)
          end
        end
      end

      def search_for_terms(extracted_terms)
        return [] if extracted_terms.blank?

        # Solr query to retrieve all the terms
        # NOTE: For terms with a pref_label and no uri, we generate the temp uri would look like.
        # NOTE: Prior validation should have caught any terms that are missing a uri or pref_label. In this part of the code,
        # we will assume that if a uri isn't provided a pref_label is provided.
        batch_lookup = {}
        extracted_terms.each do |vocabulary, terms|
          new_terms = terms.map { |t| t.key?('uri') ? t['uri'] : Term.temporary_uri(vocabulary, t['pref_label']) }
          batch_lookup[vocabulary] = new_terms
        end

        Hyacinth::Config.term_search_adapter.batch_find(batch_lookup)
      end

      # Creates new term based on the information given. Errors will be raised if there's problems with
      # term creation. A term hash of the term created is returned.
      def create_term(term, vocabulary_id, custom_field_keys)
        core_fields = term.slice(*Term::CORE_FIELDS).symbolize_keys
        custom_fields = term.slice(*custom_field_keys)
        # NOTE: Invalid fields should have been caught during validation
        term_type = term['uri'] ? Term::EXTERNAL : Term::TEMPORARY
        new_term = Term.create!(**core_fields, term_type: term_type, vocabulary_id: vocabulary_id, custom_fields: custom_fields)

        Hyacinth::DynamicFieldDataHelper.format_term(new_term, custom_field_keys)
      end

      # Looks up term and updates it based with the new update args given.
      def update_term(lookup_args, update_args, custom_field_keys)
        update_term = Term.find_by(**lookup_args)
        update_args.each do |f, v|
          if custom_field_keys.include?(f)
            update_term.set_custom_field(f, v)
          else
            update_term.send("#{f}=", v)
          end
        end
        update_term.save!

        Hyacinth::DynamicFieldDataHelper.format_term(update_term, custom_field_keys)
      end
  end
end
