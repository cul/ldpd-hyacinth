# frozen_string_literal: true
require 'json'
class Hyacinth::Adapters::ExternalIdentifierAdapter::Datacite::RestApi::V2::Data
  # a findable DOI has a minimum set of required properties
  REQUIRED_PROPERTIES_FINDABLE_DOI = [:titles,
                                      :creators,
                                      :url, # target url
                                      :publisher,
                                      :publicationYear,
                                      :types, # controlled, usually "Text"
                                      :prefix].freeze
  # As additional DataCite properties are supported, add them to this array. For example:
  # SUPPORTED_PROPERTIES = (REQUIRED_PROPERTIES_FINDABLE_DOI + [:description]).freeze
  SUPPORTED_PROPERTIES = REQUIRED_PROPERTIES_FINDABLE_DOI
  # Events used when minting a DOI, depends on desired state of minted DOI
  # see https://support.datacite.org/docs/how-do-i-make-a-findable-doi-with-the-rest-api
  DOI_MINT_EVENT = { draft: '',
                     findable: 'publish',
                     registered: 'hide' }.freeze

  attr_accessor :prefix, :default_properties, :schema_version, :data_mapping

  # Initializes a JSON payload factory for Datacite REST API requests
  # The prefix and default_properties should be configured upstream and passed from
  # the adapter.
  # @param prefix [String] the DOI prefix
  # @param default_properties [Hash]
  # @param _rest [Hash] unused placeholder to allow operation against module config without slicing
  def initialize(prefix:, default_properties: {}, data_mapping: {}, **_rest)
    @prefix = prefix
    @default_properties = default_properties.dup.freeze
    @data_mapping = data_mapping.dup.freeze
    @schema_version = 'http://datacite.org/schema/kernel-4'
  end

  # Adds the properties to the attributes hash in the format expected by DataCite (after JSONfying it).
  # @param digital_object [DigitalObject]
  # @return [Hash]
  def digital_object_properties_as_attributes(digital_object)
    attributes = { prefix: prefix, schemaVersion: @schema_version }
    return attributes unless digital_object
    datacite_properties = Hyacinth::Adapters::ExternalIdentifierAdapter::HyacinthMetadata.as_datacite_properties(digital_object, default_properties)
    attributes.merge(datacite_properties.compact).compact
  end

  # @param attributes [Hash]
  # @return [Array] symbol keys of missing required properties
  def missing_required_properties(attributes)
    REQUIRED_PROPERTIES_FINDABLE_DOI.map { |prop| prop unless attributes[prop].present? }.compact
  end

  # @param attributes [Hash]
  # @return [Boolean] true if all the DataCite required properties are present, false otherwise
  def all_required_properties_present?(attributes)
    missing_required_properties(attributes).empty?
  end

  # @param digital_object [DigitalObject]
  # @param doi_state [Symbol] doi_state can be set to one of the following: :draft, :findable, :registered
  # @param target_url [String] url to associate with minted DOI
  def build_mint(digital_object = nil, doi_state = :draft, target_url = nil)
    attributes = digital_object_properties_as_attributes(digital_object)
    attributes[:url] = target_url if target_url
    missing_required_properties = missing_required_properties(attributes)
    raise "Need metadata to mint a #{doi_state} DOI (#{missing_required_properties})" unless doi_state == :draft || missing_required_properties.empty?
    # add event, which triggers DOI state change on DataCite server
    add_event(doi_state, attributes)
    generate_json_payload(attributes)
  end

  # @param digital_object [DigitalObject]
  # @param doi_state [Symbol] doi_state can be set to one of the following: :draft, :findable, :registered
  # @param target_url [String] url to associate with minted DOI if changed
  def build_properties_update(digital_object = nil, doi_state = nil, target_url = nil)
    attributes = digital_object_properties_as_attributes(digital_object)
    attributes[:url] = target_url if target_url
    # add event, which triggers DOI state change on DataCite server
    add_event(doi_state, attributes) unless doi_state.eql?(:findable) && !all_required_properties_present?(attributes)
    generate_json_payload(attributes)
  end

  # from testing on the DataCite test API, only the following info is required (assuming other required
  # properties have already been set during a mint/update):
  # "{"data":{"type":"dois","attributes":{"prefix":"10.33555","event":"publish"}}}"
  # @param doi_state [Symbol] doi_state can be set to one of the following: :draft, :findable, :registered
  def build_state_update(doi_state)
    attributes = digital_object_properties_as_attributes(nil)
    add_event(doi_state, attributes)
    generate_json_payload(attributes)
  end

  private

    # for now, don't differentiate the event based on the current DOI state
    # state can remain :draft, but cannot return to :draft
    # @param doi_desired_state [Symbol] doi_state can be set to one of the following: :findable, :registered
    # @param attributes [Hash]
    def add_event(doi_desired_state, attributes = {})
      return attributes if doi_desired_state.nil? || doi_desired_state.eql?(:draft)
      attributes[:event] = DOI_MINT_EVENT[doi_desired_state]
      attributes
    end

    # @param attributes [Hash]
    # @return [String] returns a JSON string
    def generate_json_payload(attributes)
      JSON.generate(data: { type: 'dois', attributes: attributes })
    end
end
