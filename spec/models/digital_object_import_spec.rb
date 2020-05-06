# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DigitalObjectImport, type: :model do
  describe '#new' do
    subject(:digital_object_import) { FactoryBot.create(:digital_object_import) }

    it { is_expected.to be_a DigitalObjectImport }
    its(:batch_import) { is_expected.to be_a BatchImport }
    its(:status)       { is_expected.to eql 'pending' }
    its(:index)        { is_expected.to be 34 }
    its(:digital_object_data) do
      is_expected.to eql(
        {
          'digital_object_type': 'item',
          'descriptive_metadata': { 'title': [{ 'sort_portion': 'The', 'non_sort_portion': 'Cool Item' }], 'abstract': [{ 'abstract_value': 'some abstract' }] }
        }.to_json
      )
    end
  end
end
