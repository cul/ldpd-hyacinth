# frozen_string_literal: true

# Following module contains functionality to retrieve metadata
# from the descriptive_metadata hash from DigitalObject
class Hyacinth::Adapters::ExternalIdentifierAdapter::HyacinthMetadata
  attr_reader :descriptive_metadata, :title

  delegate :doi, :created_at, :updated_at, :first_published_at, :identifiers, :uid, to: :@digital_object

  # parse metadata from Hyacinth Digital Objects Data into a format
  # suitable for including in a Datacite REST API request as attributes
  # @param digital_object_data_arg [Hash]
  # @api public
  def initialize(digital_object)
    @digital_object = digital_object
    @descriptive_metadata = @digital_object.descriptive_metadata.dup.freeze
    @title = digital_object.generate_display_label
  end

  # the genre of an item
  # @api public
  # @return [String, nil]
  # @note only returns the first genre value
  def genre_uri
    @descriptive_metadata.dig('genre', 0, 'term', 'uri')
  end

  # the abstract of an item
  # @api public
  # @return [String, nil]
  # @note only returns the first abstract value
  def abstract
    @descriptive_metadata.dig('abstract', 0, 'value')
  end

  # the abstract of an item
  # @api public
  # @return [String, nil]
  # @note only returns the first abstract value
  def publisher
    @descriptive_metadata.dig('publisher', 0, 'value')
  end

  # the type of resource for an item
  # @api public
  # @return [String, nil]
  def type_of_resource
    @descriptive_metadata.dig('type_of_resource', 0, 'value')
  end

  # starting year of the w3cdtf-encoded Date Issued field (first 4 characters)
  # @api public
  # @return [String, nil]
  def date_issued_start_year
    @descriptive_metadata.dig('date_issued', 0, 'start_value')&.slice(0..3)
  end

  # date of the w3cdtf-encoded created Timestamp field (first 10 characters)
  # @api public
  # @return [String]
  def date_created
    created_at.strftime('%Y-%m-%d')
  end

  # date of the w3cdtf-encoded modified Timestamp field (first 10 characters)
  # @api public
  # @return [String]
  def date_modified
    updated_at.strftime('%Y-%m-%d')
  end

  # @return Hash<String> identifier type mapped to identifier value of parent publication IDs
  def parent_publication_identifiers
    ['DOI', 'ISBN', 'ISSN'].index_with { |type| parent_publication(type.downcase) }.compact
  end

  # Identifier of the parent publication
  # @api public
  # @param [String] one of 'doi', 'isbn', 'issn'
  # @return [String, nil]
  def parent_publication(type)
    @descriptive_metadata.dig('parent_publication', 0, type)
  end

  # retrieve subject topics from [@descriptive_metadata]
  # @api private
  # @return [void]
  def subject_topic_terms
    @descriptive_metadata.fetch('subject_topic', []).map { |topic| topic['term'] }
  end

  def names_for_roles(*contributor_roles)
    contributor_values(@descriptive_metadata, contributor_roles).keys
  end

  # @return nil or an array of {name: }
  def datacite_names_for_roles(*contributor_roles)
    names_for_roles(*contributor_roles)&.map { |creator_name| { name: creator_name } }
  end

  # @return nil or an array of {name:, contributorType: }
  def datacite_contributors
    contributor_values = CONTRIBUTOR_ROLES.excluding(:author).map do |contributor_role|
      datacite_names_for_roles(contributor_role).each { |value| value.merge!(contributorType: contributor_role == :editor ? 'Editor' : 'Other') }
    end
    return nil unless contributor_values.find(&:present?)
    contributor_values.flatten
  end

  # @return nil or an array of {subject:, valueUri:, subjectScheme:, schemeUri: lang: }
  def datacite_subjects
    hyacinth_subjects = subject_topic_terms
    return nil if hyacinth_subjects.empty?
    hyacinth_subjects.map { |term| { subject: term['pref_label'], valueUri: term['uri'], subjectScheme: term['authority'] }.compact }
  end

  # @return nil or a hash {resourceTypeGeneral:, resourceType:, schemaOrg:, bibtex:, citeproc:, ris: }
  def datacite_types(data_mapping = {})
    unmapped_type = { resourceTypeGeneral: type_of_resource }.compact
    [data_mapping.dig(:genre_uri, genre_uri&.to_sym), unmapped_type].find(&:present?)
  end

  # @return nil or an array of {descriptionType:, description:, lang: }
  def datacite_descriptions
    hyacinth_abstracts = [abstract].compact
    return nil if hyacinth_abstracts.empty?
    hyacinth_abstracts.map { |description| { descriptionType: 'abstract', description: description } }
  end

  # @return nil or an array of {relatedIdentifier:, relatedIdentifierType:, relationType:, resourceTypeGeneral: }
  def datacite_related_identifiers
    values = [{ relatedIdentifier: "urn:uuid:#{uid}", relatedIdentifierType: 'URN', relationType: 'IsVariantFormOf' }]
    parent_publication_identifiers&.each do |type, value|
      values << { relatedIdentifier: value, relatedIdentifierType: type, relationType: (type == 'DOI' ? 'IsVariantFormOf' : 'IsPartOf') }
    end
    values
  end

  def as_datacite_properties(default_properties = {}, data_mapping = {})
    default_properties.merge({
      titles: [{ title: self.title }],
      creators: datacite_names_for_roles(:author),
      contributors: datacite_contributors,
      descriptions: datacite_descriptions,
      types: datacite_types(data_mapping),
      publisher: self.publisher,
      relatedIdentifiers: datacite_related_identifiers,
      subjects: datacite_subjects,
      publicationYear: datacite_publication_year
    }.compact)
  end

  def datacite_publication_year
    (self.date_issued_start_year || Time.zone.today.year).to_i
  end

  def self.as_datacite_properties(digital_object, default_properties = {}, data_mapping = {})
    digital_object.blank? ? default_properties : new(digital_object).as_datacite_properties(default_properties, data_mapping)
  end

  private

    CONTRIBUTOR_ROLES = [:author, :editor, :moderator, :contributor].freeze

    def process_name(name_hash)
      return [name_hash['term']['pref_label'], [:contributor]] if name_hash['role'].blank?

      roles = name_hash['role'].map { |role| role.dig('term', 'pref_label').downcase.to_sym }
      [name_hash['term']['pref_label'], CONTRIBUTOR_ROLES & roles]
    end

    # retrieve name terms by role from [@descriptive_metadata]
    # @param Array<Symbol> filter_types optional types to filter to
    # @return Hash of contributor names to array of types
    def contributor_values(descriptive_metadata, filter_types = [])
      descriptive_metadata.fetch('name', []).map { |name| process_name(name) }.select { |key_value_pair| filter_types.blank? || (filter_types & key_value_pair[1]).present? }.to_h
    end
end
