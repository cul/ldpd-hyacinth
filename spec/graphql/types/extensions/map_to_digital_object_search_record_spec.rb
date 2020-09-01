# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Types::Extensions::MapToDigitalObjectSearchRecord do
  context "stateless methods" do
    let(:project) { FactoryBot.create(:project) }
    let(:client) do
      # do nothing with initialization; we just want to test stateless methods
      described_class.allocate
    end

    describe "#after_resolve" do
      let(:id_from_solr) { 'id_from_solr' }
      # paginated value nodes should be solr document hashes with ids
      let(:value) do
        OpenStruct.new(
          nodes: [{
            'id' => id_from_solr,
            'title_ss' => 'Glorious new item',
            'digital_object_type_ssi' => 'item',
            'projects_ssim' => [project.string_key],
            'number_of_children_isi' => 1
          }],
          page_info: OpenStruct.new
        )
      end

      let(:generated_open_struct) do
        OpenStruct.new(
          id: id_from_solr,
          title: 'Glorious new item',
          digital_object_type: 'item',
          projects: [project],
          number_of_children: 1,
          parent_ids: []
        )
      end

      it 'converts each solr document to an OpenStruct with appropriate values' do
        expect(
          client.after_resolve(object: nil, value: value, arguments: {}, context: nil, memo: nil)[:nodes].first
        ).to eql(generated_open_struct)
      end
    end
  end
end
