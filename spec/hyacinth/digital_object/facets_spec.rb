# frozen_string_literal: true

require 'rails_helper'

describe Hyacinth::DigitalObject::Facets do
  let(:descriptive_category) { FactoryBot.create(:dynamic_field_category) }
  let(:rights_category) { FactoryBot.create(:dynamic_field_category, display_label: 'Rights', metadata_form: 'item_rights') }
  let(:name_group) { FactoryBot.create(:dynamic_field_group, parent: descriptive_category) }
  let(:role_group) { FactoryBot.create(:dynamic_field_group, :child, parent: name_group) }
  let(:copyright_group) { FactoryBot.create(:dynamic_field_group, display_label: 'Copyright Status', string_key: 'copyright_status', parent: rights_category) }
  let(:term_field) { FactoryBot.create(:dynamic_field, display_label: 'Value', string_key: 'term', controlled_vocabulary: 'name', dynamic_field_group: name_group) }
  let(:role_field) { FactoryBot.create(:dynamic_field, :string, display_label: 'Value', string_key: 'value', dynamic_field_group: role_group) }
  let(:rights_field) do
    FactoryBot.create(:dynamic_field, display_label: 'Copyright Statement', string_key: 'copyright_statement',
                                      controlled_vocabulary: 'rights_statement', dynamic_field_group: copyright_group,
                                      filter_label: nil)
  end

  describe '.all_solr_keys' do
    let!(:expected) do
      [term_field, role_field, rights_field].map do |df|
        path = df.ancestor_nodes[1..-1].map(&:string_key) << df.string_key
        Hyacinth::DigitalObject::SolrKeys.for_dynamic_field(path)
      end
    end
    it { expect(described_class.all_solr_keys).to match_array(expected) }
  end
  describe '.all_facetable_fields' do
    let!(:expected) { DynamicField.where(is_facetable: true).all }
    it { expect(described_class.all_facetable_fields - expected).to eql([]) }
  end
  describe '.facet_display_label_map' do
    let!(:expected) do
      DynamicField.where(is_facetable: true).all.map { |df|
        path = df.ancestor_nodes[1..-1].map(&:string_key) << df.string_key
        [Hyacinth::DigitalObject::SolrKeys.for_dynamic_field(path), df.display_label]
      }.to_h
    end
    it { expect(described_class.facet_display_label_map).to eql(expected) }
  end
end
