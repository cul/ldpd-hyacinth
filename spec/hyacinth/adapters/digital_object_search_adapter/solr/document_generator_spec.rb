# frozen_string_literal: true

require 'rails_helper'
require 'shared_examples/digital_object_search_adapter/shared_examples'

describe Hyacinth::Adapters::DigitalObjectSearchAdapter::Solr::DocumentGenerator do
  context "#solr_document_for" do
    let(:authorized_object) { FactoryBot.build(:digital_object_test_subclass, :with_sample_data) }
    let(:adapter) { described_class.new }
    before do
      authorized_object.send :uid=, 'dummy-uid'
    end

    it "indexes the uid into id" do
      expect(adapter.solr_document_for(authorized_object)['id']).to eql(authorized_object.uid)
    end

    it "indexes the state" do
      expect(adapter.solr_document_for(authorized_object)['state_ssi']).to eql(authorized_object.state)
    end

    it "indexes the digital object type" do
      expect(adapter.solr_document_for(authorized_object)['digital_object_type_ssi']).to eql(authorized_object.digital_object_type)
    end

    it "indexes the title into title_ssi" do
      # pending("object factory field name corrections to align with title practice")
      expect(adapter.solr_document_for(authorized_object)['title_ssi']).to eql('Tall Man and His Hat')
    end

    it "does not set rights fields" do
      expect(adapter.solr_document_for(authorized_object)['rights_category_present_bi']).to be false
      expect(adapter.solr_document_for(authorized_object)['copyright_status_copyright_statement_ssi']).to eql(Hyacinth::DigitalObject::RightsFields::UNASSIGNED_STATUS_INDEX)
    end

    context "with rights data" do
      let(:rights_status) { "Non-existent rights status" }
      before do
        authorized_object.rights['copyright_status'] = [
          {
            'copyright_statement' => {
              'pref_label' => rights_status,
              'uri' => 'http://blank.org/not/a/rights/status'
            }
          }
        ]
      end
      it "sets rights fields" do
        expect(adapter.solr_document_for(authorized_object)['rights_category_present_bi']).to be true
        expect(adapter.solr_document_for(authorized_object)['copyright_status_copyright_statement_ssi']).to eql(rights_status)
      end
    end

    context "with collections data" do
      let(:collection_value) { "Non-existent collection" }
      before do
        authorized_object.descriptive['collection'] = [
          {
            'term' => {
              'pref_label' => collection_value,
              'uri' => 'http://blank.org/not/collection'
            }
          }
        ]
      end
      it "indexes the collection label into collections_ssim" do
        expect(adapter.solr_document_for(authorized_object)['collection_ssim']).to eql([collection_value])
      end
    end
  end
end
