# Following module contains functionality to create the XML
# containing the metadata, using the datacite metadata scheme
module Hyacinth::Datacite
  class DataciteMetadataBuilder
    attr_reader :attributes

    DATACITE_RELATED_ITEM_TYPE = [
      'Audiovisual',
      'Book',
      'BookChapter',
      'Collection',
      'ComputationalNotebook',
      'ConferencePaper',
      'ConferenceProceeding',
      'DataPaper',
      'Dataset',
      'Dissertation',
      'Event',
      'Image',
      'Instrument',
      'InteractiveResource',
      'Journal',
      'JournalArticle',
      'Model',
      'Other',
      'OutputManagementPlan',
      'PeerReview',
      'PhysicalObject',
      'Preprint',
      'Report',
      'Service',
      'Software',
      'Sound',
      'Standard',
      'StudyRegistration',
      'Text',
      'Workflow',
    ]

    DATACITE_RELATION_TYPE = [
      'IsCitedBy',
      'Cites',
      'IsSupplementTo',
      'IsSupplementedBy',
      'IsContinuedBy',
      'Continues',
      'Describes',
      'IsDescribedBy',
      'HasMetadata',
      'IsMetadataFor',
      'HasVersion',
      'IsVersionOf',
      'IsNewVersionOf',
      'IsPreviousVersionOf',
      'IsPartOf',
      'HasPart',
      'IsPublishedIn',
      'IsReferencedBy',
      'References',
      'IsDocumentedBy',
      'Documents',
      'IsCompiledBy',
      'Compiles',
      'IsVariantFormOf',
      'IsOriginalFormOf',
      'IsIdenticalTo',
      'IsReviewedBy',
      'Reviews',
      'IsDerivedFrom',
      'IsSourceOf',
      'IsRequiredBy',
      'Requires',
      'Obsoletes',
      'IsObsoletedBy',
      'IsCollectedBy',
      'Collects',
      'IsTranslationOf',
      'HasTranslation'
    ]

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
      add_related_items
      add_rights_list
      @attributes
    end

    def add_rights_list
      @attributes[:rightsList] = []
      if @hyacinth_metadata_retrieval.license.present?
        license = {
          rights: @hyacinth_metadata_retrieval.license.value,
          rightsUri: @hyacinth_metadata_retrieval.license.uri
        }
        @attributes[:rightsList].append license

        use_and_reprod = {
          rights: @hyacinth_metadata_retrieval.use_and_reproduction.value,
          rightsUri: @hyacinth_metadata_retrieval.use_and_reproduction.uri
        }
        @attributes[:rightsList].append use_and_reprod
      end
    end

    def process_related_item_identifiers(index)
      if (value = @hyacinth_metadata_retrieval.related_item_identifier_doi(index))
        type = 'doi'
      elsif (value = @hyacinth_metadata_retrieval.related_item_identifier_url(index))
        type = 'url'
      else
        # only other 2 possible values, for now, are issn and isbn
        type, value = @hyacinth_metadata_retrieval.related_item_identifier_first(index)
      end
      [type.upcase, value]
    end

    def related_item_hash(title,
                          relation_type,
                          related_item_type,
                          id_type,
                          id_value)
      item_hash = { titles: [ { title: title } ] }
      item_hash[:relationType] = relation_type
      item_hash[:relatedItemType] = related_item_type
      if id_type && id_value
        id_hash = { relatedItemIdentifier: id_value,
                    relatedItemIdentifierType: id_type }
        item_hash[:relatedItemIdentifier] = id_hash
      end
      item_hash
    end

    # this method will return nil if the related item info in Hyacinth is invalid.
    def process_related_item(index)
      title = @hyacinth_metadata_retrieval.related_item_title(index)
      if title.blank?
        Hyacinth::Utils::Logger.logger.error("#process_related_item: Empty Title, ignoring Related Item.")
        return nil
      end

      resource_type = @hyacinth_metadata_retrieval.related_item_type_of_resource(index)
      # only accept controlled terms from the datacite authority
      unless resource_type.authority == 'datacite'
        Hyacinth::Utils::Logger.logger.error(
          "#process_related_item: Invalid authority '#{resource_type.authority}' for Related Item Type,"\
          " ignoring Related Item."
        )
        return nil
      end
      unless DATACITE_RELATED_ITEM_TYPE.include? resource_type.value
        Hyacinth::Utils::Logger.logger.error(
          "#process_related_item: Invalid value '#{resource_type.value}' for Related Item Type,"\
          "ignoring Related Item."
        )
        return nil
      end

      relation_type = @hyacinth_metadata_retrieval.related_item_relation_type(index)
      # only accept controlled terms from the datacite authority
      unless relation_type.authority == 'datacite'
        Hyacinth::Utils::Logger.logger.error(
          "#process_related_item: Invalid authority '#{relation_type.authority}' for Relation Type,"\
          " ignoring Related Item."
        )
        return nil
      end
      # DataCite capitilizes the first letter in the relation_type, Hyacinth does not
      relation_type_value = relation_type.value.upcase_first
      unless DATACITE_RELATION_TYPE.include? relation_type_value
        Hyacinth::Utils::Logger.logger.error(
          "#process_related_item: Invalid value '#{relation_type_value}' for Relation Type,"\
          " ignoring Related Item.")
        return nil
      end

      id_type, id_value = process_related_item_identifiers(index)
      related_item_hash(title,
                        relation_type_value,
                        resource_type.value,
                        id_type,
                        id_value)
    end

    def add_related_items
      if @hyacinth_metadata_retrieval.num_related_items
        @attributes[:relatedItems] = []
        (0...@hyacinth_metadata_retrieval.num_related_items).each do |i|
          related_item = process_related_item(i)
          @attributes[:relatedItems] << related_item if related_item
        end
      end
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
      @attributes[:publisher] = DATACITE[:ezid_publisher]
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
      if DATACITE[:datacite][:genre_to_resource_type_mapping].key? hyacinth_genre_uri
        @attributes[:types] = { resourceTypeGeneral: "#{DATACITE[:datacite][:genre_to_resource_type_mapping][hyacinth_genre_uri][:attribute_general]}" }
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
