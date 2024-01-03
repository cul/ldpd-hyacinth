# Following module contains functionality to create the XML
# containing the metadata, using the datacite metadata scheme
module Hyacinth::Ezid
  class DataciteMetadataBuilder
    def initialize(hyacinth_metadata_retrieval_arg)
      @hyacinth_metadata_retrieval = hyacinth_metadata_retrieval_arg
    end

    def datacite_xml
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.resource('xmlns' => 'http://datacite.org/schema/kernel-3',
                     'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
                     'xsi:schemaLocation' => 'http://datacite.org/schema/kernel-3 http://schema.datacite.org/meta/kernel-3/metadata.xsd') do
          # required element, but not content
          # see http://ezid.cdlib.org/doc/apidoc.html#profile-datacite
          if @hyacinth_metadata_retrieval.doi_identifier.present?
            xml.identifier('identifierType' => 'DOI') { xml.text @hyacinth_metadata_retrieval.doi_identifier }
          else
            xml.identifier('identifierType' => 'DOI') { xml.text '10.0/00' }
          end
          add_title(xml)
          # required field
          xml.publisher EZID[:ezid_publisher]
          # required field
          if @hyacinth_metadata_retrieval.date_issued_start_year.present?
            xml.publicationYear @hyacinth_metadata_retrieval.date_issued_start_year
          else
            xml.publicationYear @hyacinth_metadata_retrieval.source[:created][0..3]
          end
          xml.dates do
            xml.date('dateType' => 'Created') { xml.text @hyacinth_metadata_retrieval.date_created }
            xml.date('dateType' => 'Updated') { xml.text @hyacinth_metadata_retrieval.date_modified }
          end
          add_creators xml
          add_subjects xml
          add_contributors xml
          add_resource_type xml if @hyacinth_metadata_retrieval.genre_uri
          if @hyacinth_metadata_retrieval.abstract.present?
            xml.descriptions { xml.description('descriptionType' => 'Abstract') { xml.text @hyacinth_metadata_retrieval.abstract } }
          end
          add_related_identifiers xml
        end
      end
      builder.to_xml
    end

    # required field
    def add_title(xml)
      if @hyacinth_metadata_retrieval.title.present?
        title = @hyacinth_metadata_retrieval.title
      else
        title = @hyacinth_metadata_retrieval.source[:identifiers].first
      end
      xml.titles { xml.title title }
    end

    def add_resource_type(xml)
      hyacinth_genre_uri = @hyacinth_metadata_retrieval.genre_uri.to_sym
      return unless EZID[:datacite][:genre_to_resource_type_mapping].key? hyacinth_genre_uri

      xml.resourceType('resourceTypeGeneral' =>
                       "#{EZID[:datacite][:genre_to_resource_type_mapping][hyacinth_genre_uri][:attribute_general]}") do
        xml.text "#{EZID[:datacite][:genre_to_resource_type_mapping][hyacinth_genre_uri][:content]}"
      end
    end

    def add_related_identifiers(xml)
      return if @hyacinth_metadata_retrieval.parent_publication_issn.blank?

      xml.relatedIdentifiers do
        xml.relatedIdentifier('relatedIdentifierType' => 'ISSN',
                              'relationType' => 'IsPartOf') { xml.text @hyacinth_metadata_retrieval.parent_publication_issn }
        xml.relatedIdentifier('relatedIdentifierType' => 'ISBN',
                              'relationType' => 'IsPartOf') { xml.text @hyacinth_metadata_retrieval.parent_publication_isbn }
        xml.relatedIdentifier('relatedIdentifierType' => 'DOI',
                              'relationType' => 'IsVariantFormOf') { xml.text @hyacinth_metadata_retrieval.parent_publication_doi }
      end
    end

    def add_subjects(xml)
      return if @hyacinth_metadata_retrieval.subjects_topic.empty?

      xml.subjects do
        @hyacinth_metadata_retrieval.subjects_topic.each { |topic| xml.subject topic }
      end
    end

    # required field
    def add_creators(xml)
      if @hyacinth_metadata_retrieval.creators.present?
        xml.creators do
          @hyacinth_metadata_retrieval.creators.each do |name|
            xml.creator { xml.creatorName name }
          end
        end
      else
        # required element, but not content
        # see http://ezid.cdlib.org/doc/apidoc.html#profile-datacite
        xml.creators { xml.creator { xml.creatorName '(:unav)' } }
      end
    end

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
