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
          xml.identifier('identifierType' => 'DOI') { xml.text @hyacinth_metadata_retrieval.doi_identifier }
          xml.titles { xml.title @hyacinth_metadata_retrieval.title } if @hyacinth_metadata_retrieval.title
          xml.publisher EZID[:ezid_publisher]
          xml.publicationYear @hyacinth_metadata_retrieval.date_issued_start_year
          xml.date('dateType' => 'Created') { xml.text @hyacinth_metadata_retrieval.date_created }
          xml.date('dateType' => 'Updated') { xml.text @hyacinth_metadata_retrieval.date_modified }
          add_creators xml
          add_subjects xml
          add_contributors xml
          xml.resourceType('resourceTypeGeneral' => @hyacinth_metadata_retrieval.type_of_resource)
          xml.descriptions { xml.description('descriptionType' => 'Abstract') { xml.text @hyacinth_metadata_retrieval.abstract } }
          add_related_identifiers xml
        end
      end
      builder.to_xml
    end

    def add_related_identifiers(xml)
      xml.relatedIdentifiers do
        xml.relatedIdentifier('relatedIdentifierType' => 'ISSN',
                              'relationType' => 'isPartOf') { xml.text @hyacinth_metadata_retrieval.parent_publication_issn }
        xml.relatedIdentifier('relatedIdentifierType' => 'ISBN',
                              'relationType' => 'isPartOf') { xml.text @hyacinth_metadata_retrieval.parent_publication_isbn }
        xml.relatedIdentifier('relatedIdentifierType' => 'DOI',
                              'relationType' => 'isVariantFormOf') { xml.text @hyacinth_metadata_retrieval.parent_publication_doi }
      end
    end

    def add_subjects(xml)
      xml.subjects do
        @hyacinth_metadata_retrieval.subjects_topic.each { |topic| xml.subject topic }
      end unless @hyacinth_metadata_retrieval.subjects_topic.empty?
    end

    def add_creators(xml)
      xml.creators do
        @hyacinth_metadata_retrieval.creators.each do |name|
          xml.creator { xml.creatorName name }
        end
      end
    end

    def add_contributors(xml)
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
