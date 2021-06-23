# frozen_string_literal: true
require 'json'
class Hyacinth::Adapters::ExternalIdentifierAdapter::Datacite::RestApi::V2::Data
  # a findable DOI has a minimum set of required properties
  REQUIRED_PROPERTIES_FINDABLE_DOI = [:title,
                                      :creators,
                                      :url, # target url
                                      :publisher,
                                      :publication_year,
                                      :resource_type_general, # controlled, usually "Text"
                                      :prefix].freeze
  # As additional DataCite properties are supported, add them to this array. For example:
  # SUPPORTED_PROPERTIES = (REQUIRED_PROPERTIES_FINDABLE_DOI + [:description]).freeze
  SUPPORTED_PROPERTIES = REQUIRED_PROPERTIES_FINDABLE_DOI
  # Events used when minting a DOI, depends on desired state of minted DOI
  # see https://support.datacite.org/docs/how-do-i-make-a-findable-doi-with-the-rest-api
  DOI_MINT_EVENT = { draft: '',
                     findable: 'publish',
                     registered: 'hide' }.freeze

  # parens required by rubocop
  attr_accessor(*SUPPORTED_PROPERTIES,
                :attributes,
                :data_hash)

  # @param prefix [String] the DOI prefix
  def initialize(prefix = DATACITE[:prefix])
    @prefix = prefix
    @attributes = { prefix: @prefix }
    @attributes[:schemaVersion] = 'http://datacite.org/schema/kernel-4'
    @data_hash = {}
    @data_hash[:type] = 'dois'
    @data_hash[:attributes] = @attributes
    @creators = []
  end

  # @param properties_hash [Hash] a hash containing the DataCite properties to update
  def update_properties(properties_hash = {})
    properties = properties_hash.keys & SUPPORTED_PROPERTIES
    properties.each do |prop|
      instance_variable_set("@#{prop}", properties_hash.fetch(prop))
    end
  end

  # Adds the properties to the attributes hash in the format expected by DataCite (after JSONfying it).
  def add_properties_to_attributes_hash
    unless @creators.empty?
      @attributes[:creators] = []
      @creators.each { |creator| @attributes[:creators].push(name: creator) }
    end
    @attributes[:titles] = [{ title: @title }] if @title
    @attributes[:publisher] = @publisher
    @attributes[:publicationYear] = @publication_year
    @attributes[:types] = { resourceTypeGeneral: @resource_type_general } if @resource_type_general
    @attributes[:url] = @url
    @attributes.compact!
  end

  # @return [Boolean] true if all the DataCite required properties are present, false otherwise
  def all_required_properties_present?
    # props.map { | prop| f.instance_variable_get("@#{prop}") }.any? {|val| val.nil?}
    # REQUIRED_PROPERTIES.map { | prop| instance_variable_get("@#{prop}") }.all? {|val| val.present?}
    REQUIRED_PROPERTIES_FINDABLE_DOI.map { |prop| instance_variable_get("@#{prop}") }.all?(&:present?)
  end

  # @param doi_state [Symbol] doi_state can be set to one of the following: :draft, :findable, :registered
  def build_mint(doi_state = :draft)
    raise "Need metadata to mint a #{doi_state} DOI" unless doi_state == :draft || all_required_properties_present?
    add_properties_to_attributes_hash
    # add event, which triggers DOI state change on DataCite server
    add_event(doi_state)
  end

  # @param doi_state [Symbol] doi_state can be set to one of the following: :draft, :findable, :registered
  def build_properties_update(doi_state = nil)
    add_properties_to_attributes_hash
    # add event, which triggers DOI state change on DataCite server
    add_event(doi_state) if doi_state
  end

  # from testing on the DataCite test API, only the following info is required (assuming other required
  # properties have already been set during a mint/update):
  # "{"data":{"type":"dois","attributes":{"prefix":"10.33555","event":"publish"}}}"
  # @param doi_state [Symbol] doi_state can be set to one of the following: :draft, :findable, :registered
  def build_state_update(doi_state)
    add_event(doi_state)
  end

  # @return [String] returns a JSON string
  def generate_json_payload
    JSON.generate(data: @data_hash)
  end

  # for now, don't differentiate the event based on the current DOI state
  # @param doi_desired_state [Symbol] doi_state can be set to one of the following: :draft, :findable, :registered
  # @param _doi_current_state [Symbol] doi_state can be set to one of the following: :draft, :findable, :registered
  def add_event(doi_desired_state, _doi_current_state = nil)
    @attributes[:event] = DOI_MINT_EVENT[doi_desired_state] unless doi_desired_state.eql? :draft
  end
end
