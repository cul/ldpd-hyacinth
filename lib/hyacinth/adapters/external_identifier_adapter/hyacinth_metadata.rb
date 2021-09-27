# frozen_string_literal: true

# Following module contains functionality to retrieve metadata
# from the descriptive_metadata hash from DigitalObject
class Hyacinth::Adapters::ExternalIdentifierAdapter::HyacinthMetadata
  attr_reader :descriptive_metadata, :title

  delegate :doi, :created_at, :updated_at, :first_published_at, :identifiers, to: :@digital_object

  # parse metadata from Hyacinth Digital Objects Data
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
    local_value = @descriptive_metadata.dig('date_issued', 0, 'start_value')
    local_value[0..3] if local_value
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
    {
      'ISSN' => parent_publication_issn,
      'ISBN' => parent_publication_isbn,
      'DOI' => parent_publication_doi
    }.compact
  end

  # ISSN of the parent publication
  # @api public
  # @return [String, nil]
  def parent_publication_issn
    @descriptive_metadata.dig('parent_publication', 0, 'issn')
  end

  # ISBN of the parent publication
  # @api public
  # @return [String, nil]
  def parent_publication_isbn
    @descriptive_metadata.dig('parent_publication', 0, 'isbn')
  end

  # DOI of the parent publication
  # @api public
  # @return [String, nil]
  def parent_publication_doi
    @descriptive_metadata.dig('parent_publication', 0, 'doi')
  end

  # retrieve subject topics from [@descriptive_metadata]
  # @api private
  # @return [void]
  def subject_topics
    @descriptive_metadata.fetch('subject_topic', []).map do |topic|
      topic['term']['pref_label']
    end
  end

  def names_for_roles(*contributor_roles)
    contributor_values(@descriptive_metadata, contributor_roles).keys
  end

  def as_datacite_properties(target_url = nil, default_properties = {})
    default_properties.merge({
      title: self.title,
      creators: self.names_for_roles(:author),
      resource_type_general: self.type_of_resource,
      url: target_url,
      publisher: self.publisher,
      publication_year: (self.date_issued_start_year || Time.zone.today.year).to_i
    }.compact)
  end

  def self.as_datacite_properties(digital_object, target_url, default_properties = {})
    new(digital_object).as_datacite_properties(target_url, default_properties)
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
