# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ResourceRequests::PosterJob, solr: true do
  let(:instance) { described_class.new }
  let(:asset) { FactoryBot.create(:asset, :with_master_resource, :with_access_resource, :skip_resource_request_callbacks) }

  before do
    # No ResourceRequests should exist before any of these tests.
    expect(ResourceRequest.count).to eq(0)
  end

  describe '#perform' do
    context 'when the given object is not eligible' do
      before do
        allow(described_class).to receive(:eligible_object?).and_return(false)
        instance.perform(asset.uid)
      end
      it 'does not create a ResourceRequest' do
        expect(ResourceRequest.count).to eq(0)
      end
    end

    context 'when the given object is eligible' do
      before { instance.perform(asset.uid) }
      it 'creates the expected ResourceRequest' do
        expect(ResourceRequest.count).to eq(1)
      end
    end
  end

  describe '.create_resource_request' do
    let(:src_file_location) { Derivativo::ResourceHelper.resource_location_for_derivativo(resource) }

    context 'successful run' do
      before do
        allow(described_class).to receive(:src_resource_for_digital_object).and_return(resource)
        described_class.create_resource_request(asset, resource)
      end

      context 'for a video resource' do
        let(:resource) { Hyacinth::DigitalObject::Resource.new(location: 'tracked-disk:///some/file.mp4', original_file_path: 'file.mp4', media_type: 'video/mp4') }
        it 'creates the expected ResourceRequest' do
          expect(ResourceRequest.find_by(digital_object_uid: asset.uid, job_type: 'poster_for_video', status: 'pending', src_file_location: src_file_location)).to be_a(ResourceRequest)
        end
      end
      context 'for a pdf resource' do
        let(:resource) { Hyacinth::DigitalObject::Resource.new(location: 'tracked-disk:///some/file.pdf', original_file_path: 'file.pdf', media_type: 'application/pdf') }
        it 'creates the expected ResourceRequest' do
          expect(ResourceRequest.find_by(digital_object_uid: asset.uid, job_type: 'poster_for_pdf', status: 'pending', src_file_location: src_file_location)).to be_a(ResourceRequest)
        end
      end
    end

    context 'when an unhandled file type is given' do
      context 'for a bin file' do
        let(:resource) { Hyacinth::DigitalObject::Resource.new(location: 'tracked-disk:///some/file.bin', original_file_path: 'file.bin', media_type: 'application/octet-stream') }
        it 'does not create a ResourceRequest' do
          expect(ResourceRequest.count).to eq(0)
        end
      end
    end

    context 'when a ResourceRequest with the same job_type and digital_object_uid already exists' do
      let(:resource) { Hyacinth::DigitalObject::Resource.new(location: 'tracked-disk:///some/file.mp4', original_file_path: 'file.mp4', media_type: 'video/mp4') }
      let(:job_type) { described_class.job_type_for_resource(resource) }

      before { allow(described_class).to receive(:src_resource_for_digital_object).and_return(resource) }

      ResourceRequest.statuses.each do |status_name, _status_number|
        # We expect failure when attempting to create a new ResourceRequest when one already
        # exists with status pending or in_progress, and success for any other status.
        expect_failure = ['pending', 'in_progress'].include?(status_name)

        it "#{expect_failure ? 'fails' : 'succeeds'} when existing ResourceRequest status is #{status_name}" do
          FactoryBot.create(:resource_request, digital_object_uid: asset.uid, job_type: job_type, status: status_name)
          described_class.create_resource_request(asset, resource)
          expect(ResourceRequest.count).to eq(expect_failure ? 1 : 2)
        end
      end
    end
  end

  describe '.src_resource_for_digital_object' do
    context 'when access resource is not present' do
      let(:asset) { FactoryBot.create(:asset, :with_master_resource, :skip_resource_request_callbacks) }
      it 'returns nil' do
        expect(described_class.src_resource_for_digital_object(asset)).to eq(nil)
      end
    end

    context 'when access resource is present' do
      it 'returns the access resource' do
        expect(described_class.src_resource_for_digital_object(asset)).to eq(asset.access_resource)
      end
    end
  end

  describe '.eligible_object?' do
    let(:item) { FactoryBot.create(:item) }

    it 'returns true for an non-Image Asset with a valid source resource and no existing poster resource' do
      expect(described_class.eligible_object?(asset)).to eq(true)
    end

    it 'returns false for a non-Asset digital object' do
      expect(described_class.eligible_object?(item)).to eq(false)
    end

    context 'for an Asset that already has a poster resource' do
      let(:asset) { FactoryBot.create(:asset, :with_master_resource, :with_access_resource, :with_poster_resource, :skip_resource_request_callbacks) }
      it 'returns false' do
        expect(described_class.eligible_object?(asset)).to eq(false)
      end
    end

    context 'for an Asset that has no source (i.e. access) resource' do
      let(:asset) { FactoryBot.create(:asset, :with_master_resource, :skip_resource_request_callbacks) }
      it 'returns false' do
        expect(described_class.eligible_object?(asset)).to eq(false)
      end
    end
  end
end
