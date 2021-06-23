# frozen_string_literal: true

# Following module contains functionality to retrieve metadata
# from the descriptive_metadata hash from DigitalObject
class Hyacinth::Adapters::ExternalIdentifierAdapter::HyacinthMetadata
  attr_reader :source, :descriptive_metadata
  # parse metadata from Hyacinth Digital Objects Data
  # @param digital_object_data_arg [Hash]
  # @api public
  def initialize(digital_object_data_arg)
    # dod is shorthand for digital_object_data
    @source = HashWithIndifferentAccess.new(digital_object_data_arg).freeze
    # dfd is shorthand for descriptive_metadata
    @descriptive_metadata = @source['descriptive_metadata'].dup.freeze
  end

  # DOI identifier value
  # @api public
  # @return [String, nil]
  def doi
    @source['doi']
  end

  def created_at
    deserialize_datetime(@source['created_at'])
  end

  def updated_at
    deserialize_datetime(@source['updated_at'])
  end

  def first_published_at
    deserialize_datetime(@source['first_published_at'])
  end

  def identifiers
    @source['identifiers'] || []
  end

  # the title of an item
  # @api public
  # @return [String, nil]
  # @note only returns the first title value
  def title
    return nil unless @descriptive_metadata.key? 'title'
    # concatenates the non sort portion with the sort portion
    non_sort_portion = @descriptive_metadata.dig('title', 0, 'non_sort_portion')
    sort_portion = @descriptive_metadata.dig('title', 0, 'sort_portion')
    [non_sort_portion, sort_portion].compact.join(' ')
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

  # retrieve name terms by role from [@descriptive_metadata]
  # @param Array<Symbol> filter_types optional types to filter to
  # @return Hash of contributor names to array of types
  def contributor_values(descriptive_metadata, filter_types = [])
    descriptive_metadata.fetch('name', []).map { |name| process_name(name) }.select { |key_value_pair| filter_types.blank? || (filter_types & key_value_pair[1]).present? }.to_h
  end

  def creators
    contributor_values(@descriptive_metadata, [:author]).keys
  end

  def editors
    contributor_values(@descriptive_metadata, [:editor]).keys
  end

  def moderators
    contributor_values(@descriptive_metadata, [:moderator]).keys
  end

  def contributors
    contributor_values(@descriptive_metadata, [:contributor]).keys
  end

  private

    CONTRIBUTOR_ROLES = ['author', 'editor', 'moderator', 'contributor'].freeze

    def process_name(name_hash)
      return [name_hash['term']['pref_label'], [:contributor]] if name_hash['role'].blank?

      roles = CONTRIBUTOR_ROLES & name_hash['role'].map do |role|
        role['term']['pref_label'].downcase
      end
      [name_hash['term']['pref_label'], roles.map(&:to_sym)]
    end

    def deserialize_datetime(value)
      Hyacinth::DigitalObject::TypeDef::DateTime.new.from_serialized_form_impl(value)
    end
end
