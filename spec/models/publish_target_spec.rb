require 'rails_helper'

RSpec.describe PublishTarget, type: :model do
  describe '#new' do
    context 'when all parameters correct' do
      subject(:publish_target) { FactoryBot.create(:publish_target) }

      its(:string_key) { is_expected.to eql 'great_project_website' }
      its(:display_label) { is_expected.to eql 'Great Project Website' }
      its(:publish_url) { is_expected.to eql 'https://www.example.com/publish' }
      its(:api_key) { is_expected.to eql 'bestapikey' }
    end

    context 'when string_key missing' do
      subject(:publish_target) { FactoryBot.build(:publish_target, string_key: nil) }

      it 'does not save object' do
        expect(publish_target.save).to be false
      end

      it 'returns correct error' do
        publish_target.save
        expect(publish_target.errors.full_messages).to include 'String key can\'t be blank'
      end
    end

    context 'when display_label missing' do
      subject(:publish_target) { FactoryBot.build(:publish_target, display_label: nil) }

      it 'does not save object' do
        expect(publish_target.save).to be false
      end

      it 'returns correct error' do
        publish_target.save
        expect(publish_target.errors.full_messages).to include 'Display label can\'t be blank'
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
  end
end
