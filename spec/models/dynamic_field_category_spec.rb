# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DynamicFieldCategory, type: 'model' do
  describe '#new' do
    context 'when parameters correct' do
      subject { FactoryBot.create(:dynamic_field_category) }

      it { is_expected.to be_a DynamicFieldCategory }

      its(:display_label) { is_expected.to eql 'Descriptive Metadata' }
      its(:sort_order)    { 3 }
    end

    context 'when missing display_label' do
      let(:dynamic_field_category) { FactoryBot.build(:dynamic_field_category, display_label: nil) }

      it 'does not save' do
        expect(dynamic_field_category.save).to be false
      end

      it 'returns correct error' do
        dynamic_field_category.save
        expect(dynamic_field_category.errors.full_messages).to include('Display label can\'t be blank')
      end
    end

    context 'when display_label is duplicated' do
      let(:display_label) { 'Subjects' }
      let(:dynamic_field_category) { FactoryBot.build(:dynamic_field_category, display_label: display_label) }

      before do
        FactoryBot.create(:dynamic_field_category, display_label: display_label)
      end

      it 'does not save' do
        expect(dynamic_field_category.save).to be false
      end

      it 'returns correct error' do
        dynamic_field_category.save
        expect(dynamic_field_category.errors.full_messages).to include 'Display label has already been taken'
      end
    end

    context 'when sort_order is missing' do
      let(:dynamic_field_category) { FactoryBot.create(:dynamic_field_category, sort_order: nil) }

      context 'and there are no other Dynamic Field Categories' do
        it 'sets the sort order to 0' do
          expect(dynamic_field_category.sort_order).to be 0
        end
      end

      context 'and there are other Dynamic Field Categories' do
        before do
          FactoryBot.create(:dynamic_field_category, display_label: 'Subject Data', sort_order: 2)
          FactoryBot.create(:dynamic_field_category, display_label: 'Location', sort_order: 10)
        end

        it 'sets the sort order to highest sort order (lower priority)' do
          expect(dynamic_field_category.sort_order).to be 11
        end
      end
    end
  end

  describe '#siblings' do
    subject(:dynamic_field_category) { FactoryBot.create(:dynamic_field_category) }

    it 'do not include current object' do
      dynamic_field_category.reload
      expect(dynamic_field_category.siblings).to match_array []
    end
  end
end
