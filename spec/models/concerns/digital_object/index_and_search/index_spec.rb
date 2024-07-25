require 'rails_helper'

describe DigitalObject::IndexAndSearch::Index do
  let(:pid) { 'cul:12345' }
  let(:identifiers) { ['id1', 'id2'] }
  let(:doi) { 'doi:10.7916/sa43-bk43' }
  let(:doi_without_prefix) { doi.gsub(/^doi:/, '') }
  let(:project) { Project.new(display_label: 'Sample Project') }
  let(:digital_object) {
    DigitalObject::Item.new.tap do |obj|
      obj.identifiers = identifiers
      obj.doi = doi
      allow(obj).to receive(:pid).and_return(pid)
      allow(obj).to receive(:project).and_return(project)
    end
  }

  let(:solr_doc) { digital_object.to_solr }

  describe '#to_solr' do
    context 'search_identifier_sim field' do
      it 'sets the expected values' do
        expect(solr_doc[:search_identifier_sim]).to eq([pid] + identifiers + [doi_without_prefix])
      end
    end
  end
end
