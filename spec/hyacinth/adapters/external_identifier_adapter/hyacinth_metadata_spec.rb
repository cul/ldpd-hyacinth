# frozen_string_literal: true

require 'rails_helper'

describe Hyacinth::Adapters::ExternalIdentifierAdapter::HyacinthMetadata do
  shared_context 'empty descriptive metadata' do
    let(:item_json) { file_fixture('files/datacite/ezid_item_empty_descriptive_metadata.json').read }
  end

  let(:item_json) { file_fixture('files/datacite/item.json').read }
  let(:digital_object_uid) { SecureRandom.uuid }
  let(:dod) do
    data = JSON.parse(item_json)
    data['identifiers'] = ['item.' + digital_object_uid] # random identifier to avoid collisions
    data
  end

  let(:digital_object) do
    obj = DigitalObject::Item.new
    obj.assign_attributes(dod)
    obj.uid = digital_object_uid
    date_parser = Hyacinth::DigitalObject::TypeDef::DateTime.new
    obj.created_at = date_parser.from_serialized_form(dod['created_at'])
    obj.updated_at = date_parser.from_serialized_form(dod['updated_at'])
    obj
  end

  let(:local_metadata_retrieval) { described_class.new(digital_object) }

  describe "#title" do
    let(:actual) { local_metadata_retrieval.title }
    it "returns a present value" do
      expected_full_title = 'The Catcher in the Rye'
      expect(actual).to eq(expected_full_title)
    end
    context 'no value present' do
      include_context 'empty descriptive metadata'
      it "returns UID" do
        expect(actual).to eq(digital_object_uid)
      end
    end
  end

  describe "#abstract" do
    let(:actual) { local_metadata_retrieval.abstract }
    it "returns present value" do
      expected_abstract = 'This is an abstract; yes, a very nice abstract'
      expect(actual).to eq(expected_abstract)
    end
    context 'no values present' do
      include_context 'empty descriptive metadata'
      it "returns nil" do
        expect(actual).to be_nil
      end
    end
  end

  describe "#publisher" do
    let(:actual) { local_metadata_retrieval.publisher }
    it "publisher" do
      expected_publisher = 'The Best Publisher Ever'
      expect(actual).to eq(expected_publisher)
    end
    context 'no values present' do
      include_context 'empty descriptive metadata'
      it "returns nil" do
        expect(actual).to be_nil
      end
    end
  end

  describe "#type_of_resource" do
    let(:actual) { local_metadata_retrieval.type_of_resource }
    it "type_of_resource" do
      expected_type_of_resource = 'Image'
      expect(actual).to eq(expected_type_of_resource)
    end
    context 'no values present' do
      include_context 'empty descriptive metadata'
      it "returns nil" do
        expect(actual).to be_nil
      end
    end
  end

  describe "#genre_uri" do
    let(:actual) { local_metadata_retrieval.genre_uri }
    it "genre_uri" do
      expected_genre_uri = 'http://vocab.getty.edu/aat/300048715'
      expect(actual).to eq(expected_genre_uri)
    end
    context 'no values present' do
      include_context 'empty descriptive metadata'
      it "returns nil" do
        expect(actual).to be_nil
      end
    end
  end

  describe "#date_issued_start_year" do
    let(:actual) { local_metadata_retrieval.date_issued_start_year }
    it "returns present value" do
      expected_date = '1951'
      expect(actual).to eq(expected_date)
    end
    context 'no values present' do
      include_context 'empty descriptive metadata'
      it "returns nil" do
        expect(actual).to be_nil
      end
    end
  end

  describe "#parent_publication('issn')" do
    let(:actual) { local_metadata_retrieval.parent_publication('issn') }
    it "returns present value" do
      expected_issn = '1932-6203'
      expect(actual).to eq(expected_issn)
    end
    context 'no values present' do
      include_context 'empty descriptive metadata'
      it "returns nil" do
        expect(actual).to be_nil
      end
    end
  end

  describe "#parent_publication('isbn')" do
    let(:actual) { local_metadata_retrieval.parent_publication('isbn') }
    it "returns present value" do
      expected_isbn = '0670734608'
      expect(actual).to eq(expected_isbn)
    end
    context 'no values present' do
      include_context 'empty descriptive metadata'
      it "returns nil" do
        expect(actual).to be_nil
      end
    end
  end

  describe "#parent_publication('doi')" do
    let(:actual) { local_metadata_retrieval.parent_publication('doi') }
    it "returns present value" do
      expected_doi = '10.1371/journal.pone.0119638'
      expect(actual).to eq(expected_doi)
    end
    context 'no values present' do
      include_context 'empty descriptive metadata'
      it "returns nil" do
        expect(actual).to be_nil
      end
    end
  end

  describe "#doi" do
    let(:expected) { '10.1371/article.pone.0119638' }
    let(:actual) { local_metadata_retrieval.doi }
    it "returns present value" do
      expect(actual).to eq(expected)
    end
    context 'no values present' do
      include_context 'empty descriptive metadata'
      it "returns nil" do
        expect(actual).to be_nil
      end
    end
  end

  describe "#subject_topic_terms" do
    let(:expected) do
      ['Educational attainment', 'Parental influences', 'Mother and child--Psychological aspects']
    end
    let(:actual) { local_metadata_retrieval.subject_topic_terms&.map { |v| v['pref_label'] } }
    it "returns present values" do
      expect(actual).to eq(expected)
    end
    context 'no values present' do
      include_context 'empty descriptive metadata'
      it "returns an empty array" do
        expect(actual).to eq([])
      end
    end
  end

  context "#date_created" do
    let(:expected) { '2015-02-04' }
    it "date_created" do
      actual = local_metadata_retrieval.date_created
      expect(actual).to eq(expected)
    end
  end

  context "#date_modified" do
    let(:expected) { '2016-03-31' }
    it "date_modified" do
      actual = local_metadata_retrieval.date_modified
      expect(actual).to eq(expected)
    end
  end

  describe "#names_for_roles delegators" do
    let(:actual) { local_metadata_retrieval.names_for_roles(role) }
    context 'author' do
      let(:role) { :author }
      it "parses and returns present creators" do
        expected_creators = ['Salinger, J. D.', 'Lincoln, Abraham']
        expect(actual).to eq(expected_creators)
      end
      context 'no values present' do
        include_context 'empty descriptive metadata'
        it "returns an empty array" do
          expect(actual).to eq([])
        end
      end
    end
    context 'editor' do
      let(:role) { :editor }
      it "parses and returns present editors" do
        expected_editors = ['Lincoln, Abraham']
        expect(actual).to eq(expected_editors)
      end
      context 'no values present' do
        include_context 'empty descriptive metadata'
        it "returns an empty array" do
          expect(actual).to eq([])
        end
      end
    end
    context 'moderator' do
      let(:role) { :moderator }
      it "parses and returns present moderators" do
        expected_moderators = ['Christie, Agatha']
        expect(actual).to eq(expected_moderators)
      end
      context 'no values present' do
        include_context 'empty descriptive metadata'
        it "returns an empty array" do
          expect(actual).to eq([])
        end
      end
    end
    context 'contributor' do
      let(:role) { :contributor }
      it "parses and returns present contributors" do
        expected_contributors = ["Burton, Tim"]
        expect(actual).to eq(expected_contributors)
      end
      context 'no values present' do
        include_context 'empty descriptive metadata'
        it "returns an empty array" do
          expect(actual).to eq([])
        end
      end
      context "names without roles" do
        let(:item_json) { file_fixture('files/datacite/ezid_item_names_without_roles.json').read }
        it "contributors set when name has no role" do
          expected_contributors = ['Salinger, J. D.', 'Lincoln, Abraham']
          expect(actual).to eq(expected_contributors)
        end
      end
    end
  end

  describe '#as_datacite_properties' do
    let(:default_properties) { {} }
    let(:data_mapping) { {} }
    let(:base_expected) do
      {
        creators: [{ name: "Salinger, J. D." }, { name: "Lincoln, Abraham" }],
        contributors: [
          { name: "Lincoln, Abraham", contributorType: 'Editor' },
          { name: "Christie, Agatha", contributorType: 'Other' },
          { name: "Burton, Tim", contributorType: 'Other' }
        ],
        descriptions: [
          { descriptionType: 'abstract', description: 'This is an abstract; yes, a very nice abstract' }
        ],
        publicationYear: 1951,
        publisher: "The Best Publisher Ever",
        relatedIdentifiers: [
          { relatedIdentifier: "urn:uuid:#{digital_object_uid}", relatedIdentifierType: 'URN', relationType: 'IsVariantFormOf' },
          { relatedIdentifier: '10.1371/journal.pone.0119638', relatedIdentifierType: 'DOI', relationType: 'IsVariantFormOf' },
          { relatedIdentifier: '0670734608', relatedIdentifierType: 'ISBN', relationType: 'IsPartOf' },
          { relatedIdentifier: '1932-6203', relatedIdentifierType: 'ISSN', relationType: 'IsPartOf' }
        ],
        subjects: [
          { subject: "Educational attainment", valueUri: "http://id.worldcat.org/fast/1737284" },
          { subject: "Parental influences", valueUri: "http://id.worldcat.org/fast/1053367" },
          { subject: "Mother and child--Psychological aspects", valueUri: "http://id.worldcat.org/fast/1026881" }
        ],
        types: { resourceTypeGeneral: "Image" },
        titles: [{ title: "The Catcher in the Rye" }]
      }
    end
    let(:mapped_genre) { { resourceType: "Article", resourceTypeGeneral: "Text" } }
    let(:unmapped_genre) { { resourceTypeGeneral: "Image" } }

    let(:actual) { local_metadata_retrieval.as_datacite_properties(default_properties, data_mapping) }

    context 'with data mapping configuration' do
      # keys are deeply symbolized upstream
      let(:data_mapping) do
        {
          genre_uri: {
            'http://vocab.getty.edu/aat/300048715'.to_sym => {
              resourceTypeGeneral: 'Text',
              resourceType: 'Article'
            }
          }
        }
      end
      let(:expected) { base_expected.merge(types: mapped_genre) }
      it "returns expected hash" do
        expect(actual).to eql(expected)
      end
    end
    context 'without mapping configuration' do
      let(:expected) { base_expected.merge(types: unmapped_genre) }
      it "returns expected hash" do
        expect(actual).to eql(expected)
      end
    end
    context 'no values present' do
      include_context 'empty descriptive metadata'
      it 'returns a non-zero year' do
        expect(actual[:publicationYear]).not_to be(0)
      end
    end
  end
end
