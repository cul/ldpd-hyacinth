# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DynamicFieldStructure::Path do
  describe '.collect_ancestor_nodes' do
    context 'when starting object is a DynamicFieldCategory' do
      let(:dynamic_field_category) { FactoryBot.create(:dynamic_field_category) }

      it 'return empty array' do
        expect(
          DynamicField.collect_ancestor_nodes([], dynamic_field_category)
        ).to match([])
      end

      context 'when starting object does not respond to parent' do
        let(:project) { FactoryBot.create(:project) }

        it 'raises error' do
          expect {
            DynamicField.collect_ancestor_nodes([], project)
          }.to raise_error(ArgumentError, 'Must respond to #parent in order to collect path')
        end
      end
    end
  end

  describe '#ancestor_nodes' do
    context 'when generating path for dynamic_field_group' do
      let(:dynamic_field_group_1) { FactoryBot.create(:dynamic_field_group) }
      let(:dynamic_field_group_2) { FactoryBot.create(:dynamic_field_group, :child, parent: dynamic_field_group_1) }

      let(:path) { dynamic_field_group_2.ancestor_nodes }

      it 'return list of dynamic field categories and dynamic group leading to this group' do
        expect(path.length).to be 2
        expect(path.first).to be dynamic_field_group_1.parent
        expect(path.last).to be dynamic_field_group_1
      end
    end

    context 'when generating path for dynamic_field' do
      let(:dynamic_field) { FactoryBot.create(:dynamic_field) }

      let(:path) { dynamic_field.ancestor_nodes }

      it 'returns list of dynamic field categories and group leading to this field' do
        expect(path.length).to be 2
        expect(path.first).to be dynamic_field.dynamic_field_group.parent
        expect(path.first).to be_a DynamicFieldCategory
        expect(path.last).to be dynamic_field.parent
      end
    end
  end
end
