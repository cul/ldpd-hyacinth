# frozen_string_literal: true
require 'json'
class Hyacinth::Adapters::ExternalIdentifierAdapter::Datacite::RestApi::V2::Data
  MINIMUM_REQUIRED_ATTRIBUTES_FOR_FINDABLE_DOI = [:title,
                                                  :creators,
                                                  :doi_url,
                                                  :publisher,
                                                  :publication_year,
                                                  :resource_type,
                                                  :doi_prefix].freeze
  # Events used when minting a DOI, depends on desired state of minted DOI
  # see https://support.datacite.org/docs/how-do-i-make-a-findable-doi-with-the-rest-api
  DOI_STATES = [:draft, :findable, :registered].freeze
  DOI_MINT_EVENT = { draft: '',
                     findable: 'publish',
                     registered: 'hide' }.freeze

  attr_accessor :attributes,
                :data_hash,
                :creators,
                :publisher,
                :publication_year,
                :resource_type_general, # controlled, usually "Text"
                :title,
                :url

  attr_accessor :prefix

  def initialize(prefix = DATACITE[:prefix])
    @attributes = { prefix: prefix }
    @data_hash = {}
    @data_hash[:type] = 'dois'
    @data_hash[:attributes] = @attributes
    @creators = []
  end

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
    @attributes[:schemaVersion] = 'http://datacite.org/schema/kernel-4'
    @attributes.compact!
  end

  def build_mint(doi_state = :draft, with_metadata = false)
    case doi_state
    when :draft
      add_properties_to_attributes_hash if with_metadata
    when :findable, :registered
      raise "Need metadata to mint a #{doi_state} DOI" unless with_metadata
      add_properties_to_attributes_hash
    end
    # add event, which triggers DOI state change on DataCite server
    add_event(doi_state)
  end

  def build_properties_update(doi_state = nil)
    add_properties_to_attributes_hash
    # add event, which triggers DOI state change on DataCite server
    add_event(doi_state) if doi_state
  end

  # from testing on the DataCite test API, only the following info is required:
  # "{"data":{"type":"dois","attributes":{"prefix":"10.33555","event":"publish"}}}"
  def build_state_update(doi_state)
    add_event(doi_state)
  end

  def generate_json_payload
    JSON.generate(data: @data_hash)
  end

  # for now, don't differentiate the event based on the current DOI state
  def add_event(doi_desired_state, _doi_current_state = nil)
    @attributes[:event] = DOI_MINT_EVENT[doi_desired_state] unless doi_desired_state.eql? :draft
  end
end
