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

  let(:hyc_metadata) { Hyacinth::Datacite::HyacinthMetadata.new dod }
  let(:hyc_metadata_url_no_doi) do
    Hyacinth::Datacite::HyacinthMetadata.new dod_url_no_doi
  end
  let(:hyc_metadata_no_doi_url) do
    Hyacinth::Datacite::HyacinthMetadata.new dod_no_doi_url
  end

  let(:dc_metadata) { described_class.new hyc_metadata }
  let(:dc_metadata_url_no_doi) do
    described_class.new hyc_metadata_url_no_doi
  end
  let(:dc_metadata_no_doi_url) do
    described_class.new hyc_metadata_no_doi_url
  end

  context "datacite_json" do
    let(:expected_attributes_hash) do
      { titles: [{ title: "The Catcher in the Rye" }],
        publisher: "Columbia University",
        publicationYear: "1951",
        types: { resourceTypeGeneral: "Text"},
        creators: [{ name: "Salinger, J. D." }, { name: "Lincoln, Abraham" }] }
    end

    it "produces the expected hash" do
      dc_attributes = dc_metadata.datacite_attributes
      expect(dc_attributes).to be_equivalent_to(expected_attributes_hash)
    end
  end

  context "process_related_item_identifiers" do
    it "retrieves DOI indentifier if related item has one" do
      actual_id = dc_metadata.process_related_item_identifiers(0)
      expect(actual_id).to eq(["doi", "10.33555/4363-BZ18"])
    end

    it "retrieves URL indentifier if related item no DOI but a URL identifier" do
      actual_id = dc_metadata_url_no_doi.process_related_item_identifiers(0)
      expect(actual_id).to eq(["url", "https://www.columbia.edu"])
    end

    it "retrieves ISBN indentifier if related item no DOI or URL identifier" do
      actual_id = dc_metadata_no_doi_url.process_related_item_identifiers(0)
      expect(actual_id).to eq(["isbn", "000-0-00-000000-0"])
    end
  end
end
