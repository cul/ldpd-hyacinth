require 'rails_helper'

RSpec.describe PublishTarget, type: :model do
  let(:base_attributes) { { display_label: 'Test Publish Target', publish_url: 'http://localhost/publish', api_key: 'test_api_key' } }

  # Tests don't run in transactions so we have to clean up any records created here
  after { described_class.where('string_key LIKE ?', 'doi_priority_spec_%').destroy_all }

  describe 'doi_priority validation' do
    it 'allows multiple publish targets without a doi_priority' do
      described_class.create!(base_attributes.merge(string_key: 'doi_priority_spec_a'))
      expect(described_class.new(base_attributes.merge(string_key: 'doi_priority_spec_b'))).to be_valid
    end

    it 'rejects a doi_priority that is already used by another publish target' do
      described_class.create!(base_attributes.merge(string_key: 'doi_priority_spec_a', doi_priority: 1))
      publish_target = described_class.new(base_attributes.merge(string_key: 'doi_priority_spec_b', doi_priority: 1))
      expect(publish_target).not_to be_valid
      expect(publish_target.errors[:doi_priority]).to include('is already used by another publish target')
    end

    it 'allows a publish target to be updated without changing its own doi_priority' do
      publish_target = described_class.create!(base_attributes.merge(string_key: 'doi_priority_spec_a', doi_priority: 1))
      expect(publish_target.update(display_label: 'Renamed Publish Target')).to be(true)
    end

    it 'rejects a doi_priority that is not an integer' do
      publish_target = described_class.new(base_attributes.merge(string_key: 'doi_priority_spec_a', doi_priority: 1.5))
      expect(publish_target).not_to be_valid
      expect(publish_target.errors[:doi_priority]).to be_present
    end
  end

  describe 'publish requests' do
    let(:publish_target) { described_class.new(base_attributes.merge(string_key: 'doi_priority_spec_a')) }
    let(:authorization_header) { { Authorization: 'Token token=test_api_key' } }

    it 'publishes a digital object with a PUT request to the publish url' do
      expect(RestClient).to receive(:put).with('http://localhost/publish/test:123', {}, authorization_header)
      publish_target.publish_digital_object('test:123')
    end

    it 'unpublishes a digital object with a DELETE request to the publish url' do
      expect(RestClient).to receive(:delete).with('http://localhost/publish/test:123', authorization_header)
      publish_target.unpublish_digital_object('test:123')
    end
  end
end
