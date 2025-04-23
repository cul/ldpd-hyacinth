require 'rails_helper'
require 'equivalent-xml'

describe Hyacinth::Datacite::DataciteMetadataBuilder do

  let(:dod) { JSON.parse( fixture('lib/hyacinth/datacite/hyacinth_item.json').read ) }
  let(:dod_url_no_doi) do
    JSON.parse( fixture('lib/hyacinth/datacite/hyacinth_item_rel_id_url_no_doi.json').read )
  end
  let(:dod_no_doi_url) do
    JSON.parse( fixture('lib/hyacinth/datacite/hyacinth_item_rel_id_no_doi_url.json').read )
  end
  let(:dod_invalid_rel_items) do
    JSON.parse( fixture('lib/hyacinth/datacite/hyacinth_item_invalid_related_items.json').read )
  end

  let(:hyc_metadata) { Hyacinth::Datacite::HyacinthMetadata.new dod }
  let(:hyc_metadata_url_no_doi) do
    Hyacinth::Datacite::HyacinthMetadata.new dod_url_no_doi
  end
  let(:hyc_metadata_no_doi_url) do
    Hyacinth::Datacite::HyacinthMetadata.new dod_no_doi_url
  end
  let(:hyc_metadata_invalid_rel_items) do
    Hyacinth::Datacite::HyacinthMetadata.new dod_invalid_rel_items
  end

  let(:dc_metadata) { described_class.new hyc_metadata }
  let(:dc_metadata_url_no_doi) do
    described_class.new hyc_metadata_url_no_doi
  end
  let(:dc_metadata_no_doi_url) do
    described_class.new hyc_metadata_no_doi_url
  end
  let(:dc_metadata_invalid_rel_items) do
    described_class.new hyc_metadata_invalid_rel_items
  end

  context "datacite_json" do
    let(:expected_attributes_hash) do
      {
        titles: [{title: "The Catcher in the Rye"}],
        publisher: "Columbia University",
        publicationYear: "1951",
        types: {resourceTypeGeneral: "Text"},
        creators: [
          {name: "Salinger, J. D."},
          {name: "Lincoln, Abraham" }
        ],
        relatedItems: [
          {
            titles: [{title: "The Related Item Sample Title"}],
            relationType: "IsCompiledBy",
            relatedItemType: "Image",
            relatedItemIdentifier: {
              relatedItemIdentifier: "10.33555/4363-BZ18",
              relatedItemIdentifierType: "DOI"
            }
          },
          {
            titles: [{title: "Those Are the Terms"}],
            relationType: "IsVersionOf",
            relatedItemType: "Model",
            relatedItemIdentifier: {
              relatedItemIdentifier: "https://medhealthhum.com/those-are-the-terms/",
              relatedItemIdentifierType: "URL"
            }
          }
        ],
        rightsList: [
          {
            rights: "CC BY-NC-SA 4.0",
            rightsUri: "https://creativecommons.org/licenses/by-nc-sa/4.0/"
          },
          {
            rights: "No Copyright - United States",
            rightsUri: "http://rightsstatements.org/vocab/NoC-US/1.0/"
          }
        ]
      }
    end

    it "produces the expected hash" do
      dc_attributes = dc_metadata.datacite_attributes
      expect(dc_attributes).to be_equivalent_to(expected_attributes_hash)
    end
  end

  context "process_related_item_identifiers" do
    it "retrieves DOI indentifier if related item has one" do
      actual_id = dc_metadata.process_related_item_identifiers(0)
      expect(actual_id).to eq(["DOI", "10.33555/4363-BZ18"])
    end

    it "retrieves URL indentifier if related item no DOI but a URL identifier" do
      actual_id = dc_metadata_url_no_doi.process_related_item_identifiers(0)
      expect(actual_id).to eq(["URL", "https://www.columbia.edu"])
    end

    it "retrieves ISBN indentifier if related item no DOI or URL identifier" do
      actual_id = dc_metadata_no_doi_url.process_related_item_identifiers(0)
      expect(actual_id).to eq(["ISBN", "000-0-00-000000-0"])
    end
  end

  context "related_item_hash" do
    it "creates the correct hash for the given args" do
      expected_related_item = {
        titles: [{ title: "A Sample Title" }],
        relationType: "Cites",
        relatedItemType: "Book",
        relatedItemIdentifier: {
          relatedItemIdentifier: "10.33555/4363-BZZZ",
          relatedItemIdentifierType: "DOI"
        }
      }
      actual_related_item = dc_metadata.related_item_hash("A Sample Title",
                                                          "Cites",
                                                          "Book",
                                                          "DOI",
                                                          "10.33555/4363-BZZZ")
      expect(actual_related_item).to eq(expected_related_item)
    end
  end

  context "process_related_item" do
    it "returns the expected hash for the specified related item" do
      expected_related_item = {
        titles: [{ title: "The Related Item Sample Title" }],
        relationType: "IsCompiledBy",
        relatedItemType: "Image",
        relatedItemIdentifier: {
          relatedItemIdentifier: "10.33555/4363-BZ18",
          relatedItemIdentifierType: "DOI"
        }
      }
      actual_related_item = dc_metadata.process_related_item(0)
      expect(actual_related_item).to eq(expected_related_item)
    end

    context "returns nil and logs approriate error message" do
      it "if the title of the related item is empty" do
        expect(Hyacinth::Utils::Logger.logger).to receive(:error).with(include("Empty Title"))
        actual_related_item = dc_metadata_invalid_rel_items.process_related_item(0)
        expect(actual_related_item).to be_nil
      end

      it "if the related item type is invalid" do
        expect(Hyacinth::Utils::Logger.logger).to receive(:error).with(
                                                    include("'InvalidImage' for Related Item Type"))
        actual_related_item = dc_metadata_invalid_rel_items.process_related_item(1)
        expect(actual_related_item).to be_nil
      end

      it "if the related item type authority is invalid" do
        expect(Hyacinth::Utils::Logger.logger).to receive(:error).with(
                                                    include("Invalid authority 'authorityinvalid'"))
        actual_related_item = dc_metadata_invalid_rel_items.process_related_item(2)
        expect(actual_related_item).to be_nil
      end

      it "if the relation type is invalid" do
        expect(Hyacinth::Utils::Logger.logger).to receive(:error).with(
                                                    include("'IsInvalid' for Relation Type"))
        actual_related_item = dc_metadata_invalid_rel_items.process_related_item(3)
        expect(actual_related_item).to be_nil
      end

      it "if the related item type authority is invalid" do
        expect(Hyacinth::Utils::Logger.logger).to receive(:error).with(
                                                    include("Invalid authority 'invalidauthority'"))
        actual_related_item = dc_metadata_invalid_rel_items.process_related_item(4)
        expect(actual_related_item).to be_nil
      end
    end
  end

  context "add_related_items" do
    it "populates the DataCite related items hash correctly" do
      expected_related_items = [
        {
          titles: [{ title: "The Related Item Sample Title" }],
          relationType: "IsCompiledBy",
          relatedItemType: "Image",
          relatedItemIdentifier: {
            relatedItemIdentifier: "10.33555/4363-BZ18",
            relatedItemIdentifierType: "DOI"
          }
        },
        {
          titles: [{ title: "Those Are the Terms" }],
          relationType: "IsVersionOf",
          relatedItemType: "Model",
          relatedItemIdentifier: {
            relatedItemIdentifier: "https://medhealthhum.com/those-are-the-terms/",
            relatedItemIdentifierType: "URL"
          }
        }
      ]

      dc_metadata.add_related_items
      actual_related_items = dc_metadata.attributes[:relatedItems]
      expect(actual_related_items).to eq(expected_related_items)
    end
  end

  context "add_rights_list" do
    it "populates the DataCite rights list hash correctly" do
      expected_rights_list = [
        {
          rights: "CC BY-NC-SA 4.0",
          rightsUri: "https://creativecommons.org/licenses/by-nc-sa/4.0/"
        },
        {
          rights: "No Copyright - United States",
          rightsUri: "http://rightsstatements.org/vocab/NoC-US/1.0/"
        }
      ]

      dc_metadata.add_rights_list
      actual_rights_list = dc_metadata.attributes[:rightsList]
      expect(actual_rights_list).to eq(expected_rights_list)
    end
  end
end
