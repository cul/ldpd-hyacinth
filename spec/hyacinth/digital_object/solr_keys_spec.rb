# frozen_string_literal: true

require 'rails_helper'

describe Hyacinth::DigitalObject::SolrKeys do
  let(:test_category) { FactoryBot.create(:dynamic_field_category) }
  let(:test_group) do
    FactoryBot.create(:dynamic_field_group, display_label: 'Test Fields',
                                            string_key: 'test', parent: test_category)
  end
  let(:test_field) do
    FactoryBot.create(:dynamic_field, display_label: "Field", string_key: 'field', is_facetable: true,
                                      dynamic_field_group: test_group, filter_label: "Field")
  end
  let(:path) { test_field.path[1..-1].map(&:string_key) << test_field.string_key }
  describe 'for_dynamic_field' do
    subject { described_class.for_dynamic_field(path) }
    it { is_expected.to eql('df_test_field_ssim') }
  end
end
