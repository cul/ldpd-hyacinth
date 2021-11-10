# frozen_string_literal: true

require 'rails_helper'
require 'shared_examples/digital_object_search_adapter/shared_examples'

describe Hyacinth::Adapters::DigitalObjectSearchAdapter::Solr do
  let(:adapter) { described_class.new(url: "http://nowhere.net/solr") }

  it_behaves_like "a search adapter"

  context "#solr_params_for" do
    let(:solr_params) { adapter.send(:solr_params_for, search_params) }
    context "with multiple filters on the same field" do
      let(:search_params) do
        {
          'animals' => [
            ['any value ignored', 'DOES_NOT_EXIST'], ['celocanths', 'CONTAINS'], ['elephants', 'EQUALS'],
            ['ostriches', 'DOES_NOT_CONTAIN'], ['any value ignored', 'EXISTS'], ['voles', 'DOES_NOT_EQUAL'],
            ['ferrets', 'STARTS_WITH'], ['groundhogs', 'DOES_NOT_START_WITH']
          ]
        }
      end
      let(:expected_filters) do
        [
          'state_ssi:(active)', '-animals:*', 'animals:(*celocanths*)', 'animals:(elephants)',
          '-animals:(*ostriches*)', 'animals:*', '-animals:(voles)', 'animals:(ferrets*)', '-animals:(groundhogs*)'
        ]
      end
      it "collects fq values" do
        expect(solr_params.to_h).to include(fq: expected_filters)
      end
    end
    context "with multiple values on the same filter" do
      let(:search_params) do
        {
          'animals' => [
            [
              ['aardvarks', 'celocanths', 'elephants', 'ostriches', 'panthers', 'voles'],
              'DOES_NOT_EQUAL'
            ]
          ]
        }
      end
      let(:expected_filters) do
        [
          'state_ssi:(active)', '-animals:(aardvarks OR celocanths OR elephants OR ostriches OR panthers OR voles)'
        ]
      end
      it "collects fq values" do
        expect(solr_params.to_h).to include(fq: expected_filters)
      end
    end
    context "with a search type parameter" do
      let(:search_params) { { 'search_type' => 'identifier' } }
      it "assigns df value" do
        expect(solr_params.to_h).to include(df: 'identifier_search_sim')
      end
    end
  end

  context "#solr_document_for" do
    let(:authorized_object) { FactoryBot.build(:digital_object_test_subclass, :with_sample_data) }
    let(:publication_adapter) { Hyacinth::Adapters::PublicationAdapter::Abstract.new }
    let!(:external_identifier_adapter) { Hyacinth::Adapters::ExternalIdentifierAdapter::Memory.new }

    before do
      authorized_object.send :uid=, 'dummy-uid'
      allow(Hyacinth::Config).to receive(:publication_adapter).and_return(publication_adapter)
      allow(Hyacinth::Config).to receive(:external_identifier_adapter).and_return(external_identifier_adapter)
    end

    it "delegates to an adapter" do
      delegate = instance_double(Hyacinth::Adapters::DigitalObjectSearchAdapter::Solr::DocumentGenerator)
      adapter.instance_variable_set(:@document_generator, delegate)
      expect(delegate).to receive(:solr_document_for)
      adapter.solr_document_for(authorized_object)
    end
  end

  context "#field_used_in_project?" do
    let(:project) { FactoryBot.create(:project) }
    let(:digital_object_type) { 'item' }
    let(:dynamic_field) { FactoryBot.create(:dynamic_field) }
    let(:dynamic_field_path) { dynamic_field.path }

    context "with valid arguments" do
      let(:return_value) do
        expect(adapter.solr).to receive(:get).with(
          'select',
          params: {
            'facet.field': [],
            'facet.mincount': 1,
            fq: [
              'state_ssi:(active)',
              'projects_ssim:(great_project)',
              'digital_object_type_ssi:(item)',
              'df_name_term_present_bi:(true)'
            ],
            q: nil,
            rows: 1,
            start: 0
          }
        ).and_return('response' => { 'docs' => docs })
        adapter.field_used_in_project?(dynamic_field_path, project, digital_object_type)
      end
      context "when the field is in use" do
        # Note: doc content doesn't matter for this test
        let(:docs) { [{ id: '12345' }] }
        it 'returns true' do
          expect(return_value).to eq(true)
        end
      end
      context "when the field is not in use" do
        let(:docs) { [] }
        it 'returns false' do
          expect(return_value).to eq(false)
        end
      end
    end
    context "when an path array is provided instead of a path string" do
      let(:dynamic_field_path) { ['this', 'is', 'an', 'array'] }
      it "raises an exception" do
        expect { adapter.field_used_in_project?(dynamic_field_path, project, digital_object_type) }.to raise_error(ArgumentError)
      end
    end
  end
end
