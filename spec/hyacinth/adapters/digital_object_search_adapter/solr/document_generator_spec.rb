# frozen_string_literal: true

require 'rails_helper'
require 'shared_examples/digital_object_search_adapter/shared_examples'

describe Hyacinth::Adapters::DigitalObjectSearchAdapter::Solr::DocumentGenerator do
  context "#solr_document_for" do
    subject(:document) { adapter.solr_document_for(authorized_object) }

    let(:authorized_object) { FactoryBot.build(:digital_object_test_subclass, :with_sample_data) }
    let(:adapter) { described_class.new }

    before do
      authorized_object.send :uid=, 'dummy-uid'
    end

    its(['id']) { is_expected.to eql authorized_object.uid }
    its(['state_ssi']) { is_expected.to eql authorized_object.state }
    its(['digital_object_type_ssi']) { is_expected.to eql authorized_object.digital_object_type }
    its(['title_ssi']) { is_expected.to eql('The Tall Man and His Hat') }
    its(['sort_title_ssi']) { is_expected.to eql('Tall Man and His Hat') }
    its(['created_at_dtsi']) { is_expected.to match(/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$/) }
    its(['updated_at_dtsi']) { is_expected.to match(/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$/) }

    it "does not set rights fields" do
      expect(document['rights_category_present_bi']).to be false
      expect(document['copyright_status_copyright_statement_ssi']).to eql(Hyacinth::DigitalObject::RightsFields::UNASSIGNED_STATUS_INDEX)
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
        expect(document['rights_category_present_bi']).to be true
        expect(document['copyright_status_copyright_statement_ssi']).to eql(rights_status)
      end
    end

    context "with collections data" do
      let(:collection_value) { "Non-existent collection" }

      before do
        authorized_object.descriptive_metadata['collection'] = [
          {
            'term' => {
              'pref_label' => collection_value,
              'uri' => 'http://blank.org/not/collection'
            }
          }
        ]
      end

      it "indexes the collection label into collections_ssim" do
        expect(document['collection_ssim']).to eql([collection_value])
      end
    end
  end
end
