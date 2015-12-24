require 'rails_helper'

describe ExportSearchResultsToCsvJob, :type => :unit do
  describe '.map_temp_field_indexes' do
    let(:doc1) do
      {'something' => ['thing'], 'dynamic_field_data' => {'characteristic' => 'value'}}
    end
    let(:doc2) do
      {'something' => ['thing','other'], 'dynamic_field_data' => {'characteristic' => 'value'}}
    end
    let(:user) { double(User) }
    let(:search_params) { Hash.new }
    let(:expected) do
      {
        '_pid' => 0,
        '_project.string_key' => 1,
        '_something-1' => 2,
        'characteristic' => 3,
        '_something-2' => 4
      }
    end
    before do
      allow(DigitalObject::Base).to receive(:search_in_batches)
      .and_yield(doc1).and_yield(doc2)
    end
    subject { ExportSearchResultsToCsvJob.map_temp_field_indexes(search_params, user) }
    it do
      skip 'todo'
      #is_expected.to eql expected
    end
  end
end
