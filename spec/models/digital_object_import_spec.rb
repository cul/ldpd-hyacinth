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
          'assign_uid': '2f4e2917-26f5-4d8f-968c-a4015b10e50f', 'digital_object_type': 'item', 'descriptive_metadata': { 'abstract': [{ 'value': 'some abstract' }] },
          'primary_project': { 'string_key': 'great_project' }, 'title': { 'value': { 'sort_portion': 'The', 'non_sort_portion': 'Cool Item' } }
        }.to_json
      )
    end
  end
end
