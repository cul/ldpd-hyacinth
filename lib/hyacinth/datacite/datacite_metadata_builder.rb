# Following module contains functionality to create the XML
# containing the metadata, using the datacite metadata scheme
module Hyacinth::Datacite
  class DataciteMetadataBuilder
    def initialize(hyacinth_metadata_retrieval_arg)
      @hyacinth_metadata_retrieval = hyacinth_metadata_retrieval_arg
      @attributes = {}
    end

    def datacite_attributes
      add_title
      add_publisher
      add_publication_year
      add_resource_type
      add_creators
      @attributes
    end

    def process_related_item_identifiers(index)
      if (value = related_item_identifier_doi(index))
        type = 'DOI'
      elsif (value = related_item_identifier_url(index))
        type = 'URL'
      else
        # only other 2 possible values, for now, are issn and isbn
        type, value = related_item_identifier_first(index)
      end
      [type.upcase, value]
    end

    # required field
    # fcd1, 12/16/21: DataCite REST API compliant
    def add_title
      if @hyacinth_metadata_retrieval.title.present?
        title = @hyacinth_metadata_retrieval.title
      else
        title = @hyacinth_metadata_retrieval.source[:identifiers].first
      end
      @attributes[:titles] = [{ title: title }]
    end

    # required field
    # fcd1, 12/16/21: DataCite REST API compliant
    def add_creators
      @attributes[:creators] = []
      if @hyacinth_metadata_retrieval.creators.present?
        @hyacinth_metadata_retrieval.creators.each do |name|
          @attributes[:creators] << { name: name }
        end
      else
        # required element, but no content. Use ':unav'
        # https://support.datacite.org/docs/datacite-metadata-schema-v44-standard-values-for-unknown-information
        @attributes[:creators] << { name: ':unav' }
      end
    end

    # required field
    # fcd1, 12/16/21: DataCite REST API compliant
    def add_publisher
      # fcd1, 12/16/21: same one-liner as existing code
      @attributes[:publisher] = EZID[:ezid_publisher]
    end

    # required field
    # fcd1, 12/16/21: DataCite REST API compliant
    def add_publication_year
      if @hyacinth_metadata_retrieval.date_issued_start_year.present?
        @attributes[:publicationYear] = @hyacinth_metadata_retrieval.date_issued_start_year
      else
        @attributes[:publicationYear] = @hyacinth_metadata_retrieval.source[:created][0..3]
      end
    end

    # required field
    # fcd1, 12/16/21: DataCite REST API compliant
    def add_resource_type
      hyacinth_genre_uri = @hyacinth_metadata_retrieval.genre_uri&.to_sym
      if EZID[:datacite][:genre_to_resource_type_mapping].key? hyacinth_genre_uri
        @attributes[:types] = { resourceTypeGeneral: "#{EZID[:datacite][:genre_to_resource_type_mapping][hyacinth_genre_uri][:attribute_general]}" }
      else
        # required element, but no content. If use ':unav', DataCite REST API generates error as follows:
        # The value ':unav' is not an element of the set {'Audiovisual', ....}
        # Therefore, will use a default of Text
        @attributes[:types] = { resourceTypeGeneral: 'Text' }
      end
    end

    # fcd1, 12/23/21: Left this here as a reminder that following needs to be moved to DataCite REST API
    # once metadata mapping is confirmed
    def add_related_identifiers(xml)
      xml.relatedIdentifiers do
        xml.relatedIdentifier('relatedIdentifierType' => 'ISSN',
                              'relationType' => 'IsPartOf') { xml.text @hyacinth_metadata_retrieval.parent_publication_issn }
        xml.relatedIdentifier('relatedIdentifierType' => 'ISBN',
                              'relationType' => 'IsPartOf') { xml.text @hyacinth_metadata_retrieval.parent_publication_isbn }
        xml.relatedIdentifier('relatedIdentifierType' => 'DOI',
                              'relationType' => 'IsVariantFormOf') { xml.text @hyacinth_metadata_retrieval.parent_publication_doi }
      end unless @hyacinth_metadata_retrieval.parent_publication_issn.blank?
    end

    # fcd1, 12/23/21: Left this here as a reminder that following needs to be moved to DataCite REST API
    # once metadata mapping is confirmed
    def add_subjects(xml)
      xml.subjects do
        @hyacinth_metadata_retrieval.subjects_topic.each { |topic| xml.subject topic }
      end unless @hyacinth_metadata_retrieval.subjects_topic.empty?
    end

    # fcd1, 12/23/21: Left this here as a reminder that following needs to be moved to DataCite REST API
    # once metadata mapping is confirmed
    def add_contributors(xml)
      return unless [:editors, :moderators, :contributors]
                    .map { |accessor| @hyacinth_metadata_retrieval.send(accessor) }
                    .find { |set| !set.empty? }
      xml.contributors do
        @hyacinth_metadata_retrieval.editors.each do |name|
          xml.contributor('contributorType' => 'Editor') { xml.contributorName name }
        end
        @hyacinth_metadata_retrieval.moderators.each do |name|
          xml.contributor('contributorType' => 'Other') { xml.contributorName name }
        end
        @hyacinth_metadata_retrieval.contributors.each do |name|
          xml.contributor('contributorType' => 'Other') { xml.contributorName name }
        end
      end
    end
  end
end
