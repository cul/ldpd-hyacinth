# frozen_string_literal: true

require 'rails_helper'

describe Hyacinth::DigitalObject::SolrKeys do
  let(:single_word_test_field) do
    FactoryBot.create(:dynamic_field, display_label: "Field", string_key: 'field', is_facetable: true,
                                      filter_label: "Field")
  end
  let(:multi_word_test_field) do
    FactoryBot.create(:dynamic_field, display_label: "Other Field", string_key: 'other_field', is_facetable: true,
                                      filter_label: "Other Field")
  end

  describe '.for_string_key_path' do
    it 'returns the expected value for single word path pieces' do
      expect(described_class.for_string_key_path(['what', 'a', 'cool', 'path'], 'sm')).to eq('what_a_cool_path_sm')
    end
    it 'returns the expected value for a multi word path pieces' do
      expect(described_class.for_string_key_path(['that_is', 'a_very', 'good_path'], 'sm')).to eq('thatIs_aVery_goodPath_sm')
    end
    it 'raises an error when a non-array is provided to the path parameter' do
      expect { described_class.for_string_key_path('wrong/path/format').to raise_error(ArgumentError) }
    end
  end

  describe '.for_dynamic_field' do
    it 'returns the expected value for a single word test field' do
      expect(described_class.for_dynamic_field(single_word_test_field.path.split('/'))).to eq('df_name_field_ssim')
    end
    it 'returns the expected value for a multi word test field' do
      expect(described_class.for_dynamic_field(multi_word_test_field.path.split('/'))).to eq('df_name_otherField_ssim')
    end
  end

  describe '.for_dynamic_field_presence' do
    it 'returns the expected value for a single word test field' do
      expect(described_class.for_dynamic_field_presence(single_word_test_field.path.split('/'))).to eq('df_name_field_present_bi')
    end
    it 'returns the expected value for a multi word test field' do
      expect(described_class.for_dynamic_field_presence(multi_word_test_field.path.split('/'))).to eq('df_name_otherField_present_bi')
    end
  end
end
