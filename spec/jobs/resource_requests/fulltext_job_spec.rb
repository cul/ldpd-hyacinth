# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ResourceRequests::FulltextJob do
  include_context 'with stubbed search adapters'
  let(:instance) { described_class.new }
  let(:asset) { FactoryBot.create(:asset, :with_main_resource, :with_access_resource, :skip_resource_request_callbacks) }

  before do
    # No ResourceRequests should exist before any of these tests.
    expect(ResourceRequest.count).to eq(0)
  end

  describe '.create_resource_request' do
    let(:src_file_location) { Hyacinth::DigitalObject::ResourceHelper.resource_location_uri(resource) }
    let(:resource) { Hyacinth::DigitalObject::Resource.new(location: 'tracked-disk:///some/file.doc', original_file_path: 'file.doc', media_type: 'application/msword') }

    before { allow(described_class).to receive(:src_resource_for_digital_object).and_return(resource) }

    context 'successful run' do
      before do
        allow(described_class).to receive(:src_resource_for_digital_object).and_return(resource)
        described_class.create_resource_request(asset, resource)
      end

      it 'creates the expected ResourceRequest' do
        described_class.create_resource_request(asset, resource)
        expect(ResourceRequest.find_by(digital_object_uid: asset.uid, job_type: 'fulltext', status: 'pending', src_file_location: src_file_location)).to be_a(ResourceRequest)
      end
    end

    context 'when a ResourceRequest with the same job_type and digital_object_uid already exists' do
      ResourceRequest.statuses.each do |status_name, _status_number|
        # We expect failure when attempting to create a new ResourceRequest when one already
        # exists with status pending or in_progress, and success for any other status.
        expect_failure = ['pending', 'in_progress'].include?(status_name)

        it "#{expect_failure ? 'fails' : 'succeeds'} when existing ResourceRequest status is #{status_name}" do
          FactoryBot.create(:resource_request, digital_object_uid: asset.uid, job_type: 'fulltext', status: status_name)
          described_class.create_resource_request(asset, resource)
          expect(ResourceRequest.count).to eq(expect_failure ? 1 : 2)
        end
      end
    end
  end

  describe '.src_resource_for_digital_object' do
    it 'returns the main resource' do
      expect(described_class.src_resource_for_digital_object(asset)).to eq(asset.main_resource)
    end
  end

  describe '.eligible_object?' do
    let(:item) { FactoryBot.create(:item) }

    it 'returns true for an Asset with a valid source resource and no existing fulltext resource' do
      expect(described_class.eligible_object?(asset)).to eq(true)
    end

    it 'returns false for a non-Asset digital object' do
      expect(described_class.eligible_object?(item)).to eq(false)
    end

    context 'for an Asset that already has a fulltext resource' do
      let(:asset) { FactoryBot.create(:asset, :with_main_resource, :with_fulltext_resource, :skip_resource_request_callbacks) }
      it 'returns false' do
        expect(described_class.eligible_object?(asset)).to eq(false)
      end
    end
  end
end
