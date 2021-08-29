# frozen_string_literal: true

require 'rails_helper'
require 'shared_examples/digital_object_search_adapter/shared_examples'

describe Hyacinth::Adapters::DigitalObjectSearchAdapter::Solr::DocumentGenerator do
  context "#solr_document_for" do
    subject(:document) { adapter.solr_document_for(authorized_object) }

    let(:authorized_object) { FactoryBot.build(:item, :with_ascii_title, :with_timestamps) }
    let(:adapter) { described_class.new }
    before do
      authorized_object.uid = 'dummy-uid'
      authorized_object.created_at = DateTime.current
      authorized_object.updated_at = DateTime.current
    end

    its(['id']) { is_expected.to eql authorized_object.uid }
    its(['state_ssi']) { is_expected.to eql authorized_object.state }
    its(['digital_object_type_ssi']) { is_expected.to eql authorized_object.digital_object_type }
    its(['display_label_ss']) { is_expected.to eql('The Best Item Ever') }
    its(['title_sortPortion_ssi']) { is_expected.to eql('Best Item Ever') }
    its(['created_at_dtsi']) { is_expected.to match(/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$/) }
    its(['updated_at_dtsi']) { is_expected.to match(/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$/) }

    it "does not set rights fields" do
      expect(document['rights_category_present_bi']).to be false
    end

    context "with rights" do
      let(:rights_status) { "Non-existent rights status" }

      before do
        DynamicFieldsHelper.load_sample_item_rights_fields!
        authorized_object.rights['copyright_status'] = [
          {
            'copyright_statement' => {
              'pref_label' => rights_status,
              'uri' => 'http://blank.org/not/a/rights/status'
            },
            'note' => 'something',
            'copyright_expiration_date' => '2002-02-04'
          }
        ]
      end

      it "adds correct fields" do
        expect(document['df_copyrightStatus_copyrightStatement_ssim']).to match_array [rights_status]
        expect(document['df_copyrightStatus_note_ssim']).to be nil
        expect(document['df_copyrightStatus_copyrightExpirationDate_ssim']).to match_array ['2002-02-04']
      end

      it "sets rights fields" do
        expect(document['rights_category_present_bi']).to be true
      end
    end

    context 'with descriptive_metadata' do
      let(:authorized_object) { FactoryBot.build(:item, :with_ascii_title, :with_timestamps, descriptive_metadata: descriptive_metadata) }
      let(:isbn_values) { ['0-4975-5421-6', '0-3831-5430-8'] }
      let(:descriptive_metadata) do
        {
          'name' => [
            {
              'term' => { 'pref_label' => 'Random, Person', 'uri' => 'http://blank.org/random/person' },
              'role' => [
                { 'term' => { 'pref_label' => 'writer', 'uri' => 'http://blank.org/writer' } },
                { 'term' => { 'pref_label' => 'author', 'uri' => 'http://blank.org/author' } }
              ]
            }
          ],
          'alternative_title' => [
            { 'value' => 'Other Title' },
            { 'value' => 'New Title' }
          ],
          'isbn' => isbn_values.map { |value| { 'value' => value } },
          'note' => [
            { 'value' => 'This is a great note!' }
          ],
          'abstract' => [
            { 'value' => '' } # Intentionally left blank to test field presence/absence indexing
          ]
        }
      end

      before do
        DynamicFieldsHelper.load_name_fields!
        DynamicFieldsHelper.load_alternative_title_fields!
        DynamicFieldsHelper.load_isbn_fields!
        DynamicFieldsHelper.load_note_fields!
        DynamicFieldsHelper.load_abstract_fields!
      end

      it 'adds correct fields' do
        expect(document['title_nonSortPortion_ssi']).to eql 'The'
        expect(document['title_sortPortion_ssi']).to eql 'Best Item Ever'
        expect(document['df_name_term_ssim']).to match_array ['Random, Person']
        expect(document['df_name_role_term_ssim']).to match_array ['writer', 'author']
        expect(document['df_alternativeTitle_value_ssim']).to match_array ['Other Title', 'New Title']
        expect(document['df_isbn_value_ssim']).to match_array isbn_values
      end

      it 'does not index the value of the note field because it is of type textarea' do
        expect(document['df_note_value_ssim']).to eq(nil)
      end

      it 'indexes presence of all non-textarea fields' do
        expect(document['df_name_term_present_bi']).to eq(true)
        expect(document['df_name_role_term_present_bi']).to eq(true)
        expect(document['df_alternativeTitle_value_present_bi']).to eq(true)
        expect(document['df_isbn_value_present_bi']).to eq(true)
      end

      it 'indexes the presence of all textarea fields' do
        expect(document['df_note_value_present_bi']).to eq(true)
      end

      it 'only adds presence keys for non-blank fields' do
        expect(document.keys.select { |key| key.match?(/df_.+_present_bi/) }).to match_array(
          [
            'df_name_term_present_bi', 'df_name_role_term_present_bi', 'df_alternativeTitle_value_present_bi',
            'df_isbn_value_present_bi', 'df_note_value_present_bi'
          ]
        )
      end

      it 'adds values to keyword search' do
        expect(document['keyword_search_teim']).to match_array(
          ['Other Title', 'New Title', 'The Best Item Ever', 'Random, Person']
        )
      end

      it 'adds values to title search' do
        expect(document['title_search_teim']).to match_array(
          ['Other Title', 'New Title', 'The Best Item Ever']
        )
      end

      context "identifier-scoped indexing" do
        let(:fedora_pid) { 'test:pid' }
        let(:preservation_target_uris) { ["fedora3://#{fedora_pid}"] }
        before do
          authorized_object.preservation_target_uris.merge(preservation_target_uris)
        end
        it 'adds uid to identifier search' do
          expect(document['identifier_search_sim']).to include(authorized_object.uid)
        end

        it 'adds values from identifier-scoped fields to identifier search' do
          expect(document['identifier_search_sim']).to include(*isbn_values)
        end

        it 'adds values from preservation uris to identifier search' do
          expect(document['identifier_search_sim']).to include(fedora_pid)
        end
      end
    end
  end
end
