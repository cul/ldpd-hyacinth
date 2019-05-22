# Following module contains functionality to create the XML
# containing the metadata, using the datacite metadata scheme
class Hyacinth::Adapters::ExternalIdentifierAdapter::Datacite::MetadataBuilder
  def initialize(hyacinth_metadata)
    @hyacinth_metadata = hyacinth_metadata
  end

  def datacite_xml
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.resource('xmlns' => 'http://datacite.org/schema/kernel-3',
                   'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
                   'xsi:schemaLocation' => 'http://datacite.org/schema/kernel-3 http://schema.datacite.org/meta/kernel-3/metadata.xsd') do
        # required element, but not content
        # see http://ezid.cdlib.org/doc/apidoc.html#profile-datacite
        if @hyacinth_metadata.doi.present?
          xml.identifier('identifierType' => 'DOI') { xml.text @hyacinth_metadata.doi }
        else
          xml.identifier('identifierType' => 'DOI') { xml.text '10.0/00' }
        end
        add_title(xml)
        # required field
        xml.publisher DATACITE[:ezid_publisher]
        # required field
        if @hyacinth_metadata.date_issued_start_year || @hyacinth_metadata.first_published_at.present?
          xml.publicationYear @hyacinth_metadata.date_issued_start_year || @hyacinth_metadata.first_published_at.year
        else
          xml.publicationYear @hyacinth_metadata.created_at.year
        end
        xml.dates do
          xml.date('dateType' => 'Created') { xml.text @hyacinth_metadata.created_at.strftime('%Y-%m-%d') }
          xml.date('dateType' => 'Updated') { xml.text @hyacinth_metadata.updated_at.strftime('%Y-%m-%d') }
        end
        add_creators xml
        add_subjects xml
        add_contributors xml
        add_resource_type xml
        if @hyacinth_metadata.abstract.present?
          xml.descriptions do
            xml.description('descriptionType' => 'Abstract') { xml.text @hyacinth_metadata.abstract }
          end
        end
        add_related_identifiers xml
      end
    end
    builder.to_xml
  end

  # required field
  def add_title(xml)
    title = @hyacinth_metadata.title
    title = @hyacinth_metadata.identifiers.first unless title.present?
    xml.titles { xml.title title }
  end

  def add_resource_type(xml)
    hyacinth_genre = DATACITE[:datacite][:genre_to_resource_type_mapping][@hyacinth_metadata.genre_uri&.to_sym]
    return unless hyacinth_genre
    xml.resourceType('resourceTypeGeneral' => hyacinth_genre[:attribute_general].to_s) do
      xml.text hyacinth_genre[:content].to_s
    end
  end

  def add_related_identifiers(xml)
    parent_publication_ids = @hyacinth_metadata.parent_publication_identifiers
    return if parent_publication_ids.blank?
    xml.relatedIdentifiers do
      parent_publication_ids.each do |type, value|
        relation_type = type.eql?('DOI') ? 'IsVariantFormOf' : 'IsPartOf'
        xml.relatedIdentifier('relatedIdentifierType' => type, 'relationType' => relation_type) { xml.text value }
      end
    end
  end

  def add_subjects(xml)
    subject_topics = @hyacinth_metadata.subject_topics
    return if subject_topics.blank?
    xml.subjects do
      subject_topics.each { |topic| xml.subject topic }
    end
  end

  # required field
  def add_creators(xml)
    creators = creator_values(@hyacinth_metadata)
    if creators.present?
      xml.creators do
        creators.each do |name|
          xml.creator { xml.creatorName name }
        end
      end
    else
      # required element, but not content
      # see http://ezid.cdlib.org/doc/apidoc.html#profile-datacite
      xml.creators { xml.creator { xml.creatorName '(:unav)' } }
    end
  end

  def creator_values(hyacinth_metadata)
    # TODO: return creators from dynamic field data
    hyacinth_metadata.creators
  end

  def add_contributors(xml)
    contributors = @hyacinth_metadata.contributor_values(@hyacinth_metadata.dynamic_field_data, [:editor, :moderator, :contributor])
    contributors.reject! { |_contributor, types| types.blank? || types.eql?([:creator]) }
    return if contributors.blank?

    xml.contributors do
      contributors.each do |name, types|
        if types.include?(:editor)
          xml.contributor('contributorType' => 'Editor') { xml.contributorName name }
        else
          xml.contributor('contributorType' => 'Other') { xml.contributorName name }
        end
      end
    end
  end
end
