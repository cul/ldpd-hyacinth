require 'rails_helper'
require 'equivalent-xml'

describe Hyacinth::Datacite::DataciteMetadataBuilder do

  let(:metadata_builder) { described_class.new metadata_retrieval }

  let(:metadata_retrieval) { Hyacinth::Datacite::HyacinthMetadata.new dod }

  context "datacite_json" do
    let(:dod) { JSON.parse( fixture('lib/hyacinth/datacite/hyacinth_item.json').read ) }
    let(:expected_attributes_hash) do
      { titles: [{ title: "The Catcher in the Rye" }],
        publisher: "Columbia University",
        publicationYear: "1951",
        types: { resourceTypeGeneral: "Text"},
        creators: [{ name: "Salinger, J. D." }, { name: "Lincoln, Abraham" }] }
    end
    subject { metadata_builder.datacite_attributes }
    it "produces the expected hash" do
      expect(subject).to be_equivalent_to(expected_attributes_hash)
    end
  end
end
