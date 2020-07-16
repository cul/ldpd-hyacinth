# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PublishTarget, type: :model do
  describe '#new' do
    context 'when all parameters correct' do
      subject(:publish_target) { FactoryBot.create(:publish_target) }

      its(:target_type) { is_expected.to eql 'production' }
      its(:publish_url) { is_expected.to eql 'https://www.example.com/publish' }
      its(:api_key) { is_expected.to eql 'bestapikey' }
      its(:is_allowed_doi_target) { is_expected.to be false }
      its(:doi_priority) { is_expected.to be 100 }
      its(:project) { is_expected.to eql Project.find_by(string_key: 'great_project') }
    end

    context 'when target_type missing' do
      subject(:publish_target) { FactoryBot.build(:publish_target, target_type: nil) }

      it 'does not save object' do
        expect(publish_target.save).to be false
      end

      it 'returns correct error' do
        publish_target.save
        expect(publish_target.errors.full_messages).to include 'Target type can\'t be blank'
      end
    end

    context 'when publish_url missing' do
      subject(:publish_target) { FactoryBot.build(:publish_target, publish_url: nil) }

      it 'does not save object' do
        expect(publish_target.save).to be false
      end

      it 'returns correct error' do
        publish_target.save
        expect(publish_target.errors.full_messages).to include 'Publish url can\'t be blank'
      end
    end

    context 'when api_key missing' do
      subject(:publish_target) { FactoryBot.build(:publish_target, api_key: nil) }

      it 'does not save object' do
        expect(publish_target.save).to be false
      end

      it 'returns correct error' do
        publish_target.save
        expect(publish_target.errors.full_messages).to include 'Api key can\'t be blank'
      end
    end

    context 'when doi_priority is not between 1 and 100' do
      subject(:publish_target) { FactoryBot.build(:publish_target, doi_priority: 101) }

      it 'does not save object' do
        expect(publish_target.save).to be false
      end

      it 'returns correct error' do
        publish_target.save
        expect(publish_target.errors.full_messages).to include 'Doi priority must be less than or equal to 100'
      end
    end
  end
end
