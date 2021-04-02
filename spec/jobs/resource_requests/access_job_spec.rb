# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ResourceRequests::AccessJob, solr: true do
  let(:instance) { described_class.new }
  let(:asset) { FactoryBot.create(:asset, :with_master_resource, :skip_resource_request_callbacks) }

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

      context 'for an image resource' do
        let(:resource) { Hyacinth::DigitalObject::Resource.new(location: 'tracked-disk:///some/file.png', original_file_path: 'file.png', media_type: 'image/png') }
        it 'creates the expected ResourceRequest' do
          res_req = ResourceRequest.find_by(digital_object_uid: asset.uid, job_type: 'access_for_image', status: 'pending', src_file_location: src_file_location)
          expect(res_req).to be_a(ResourceRequest)
          expect(res_req.options).to eq(rotation: '0')
        end
      end
      context 'for a video resource' do
        let(:resource) { Hyacinth::DigitalObject::Resource.new(location: 'tracked-disk:///some/file.mp4', original_file_path: 'file.mp4', media_type: 'video/mp4') }
        it 'creates the expected ResourceRequest' do
          expect(ResourceRequest.find_by(digital_object_uid: asset.uid, job_type: 'access_for_video', status: 'pending', src_file_location: src_file_location)).to be_a(ResourceRequest)
        end
      end
      context 'for an audio resource' do
        let(:resource) { Hyacinth::DigitalObject::Resource.new(location: 'tracked-disk:///some/file.m4a', original_file_path: 'file.m4a', media_type: 'audio/m4a') }
        it 'creates the expected ResourceRequest' do
          expect(ResourceRequest.find_by(digital_object_uid: asset.uid, job_type: 'access_for_audio', status: 'pending', src_file_location: src_file_location)).to be_a(ResourceRequest)
        end
      end
      context 'for a pdf resource' do
        let(:resource) { Hyacinth::DigitalObject::Resource.new(location: 'tracked-disk:///some/file.pdf', original_file_path: 'file.pdf', media_type: 'application/pdf') }
        it 'creates the expected ResourceRequest' do
          expect(ResourceRequest.find_by(digital_object_uid: asset.uid, job_type: 'access_for_pdf', status: 'pending', src_file_location: src_file_location)).to be_a(ResourceRequest)
        end
      end
      context 'for a text resource' do
        let(:resource) { Hyacinth::DigitalObject::Resource.new(location: 'tracked-disk:///some/file.txt', original_file_path: 'file.txt', media_type: 'text/plain') }
        it 'creates the expected ResourceRequest' do
          expect(
            ResourceRequest.find_by(digital_object_uid: asset.uid, job_type: 'access_for_text_or_office_document', status: 'pending', src_file_location: src_file_location)
          ).to be_a(ResourceRequest)
        end
      end
      context 'for an office document resource' do
        let(:resource) { Hyacinth::DigitalObject::Resource.new(location: 'tracked-disk:///some/file.doc', original_file_path: 'file.doc', media_type: 'application/msword') }
        it 'creates the expected ResourceRequest' do
          expect(
            ResourceRequest.find_by(digital_object_uid: asset.uid, job_type: 'access_for_text_or_office_document', status: 'pending', src_file_location: src_file_location)
          ).to be_a(ResourceRequest)
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
      let(:resource) { Hyacinth::DigitalObject::Resource.new(location: 'tracked-disk:///some/file.png', original_file_path: 'file.png', media_type: 'image/png') }
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

  describe '.generate_base_resource_request_args' do
    let(:image_resource) do
      Hyacinth::DigitalObject::Resource.new(
        original_file_path: '/old/path/to/file',
        checksum: 'sha256:asdf',
        file_size: 1234,
        location: "managed-disk://#{Rails.root.join('spec', 'fixtures', 'files', 'test.png')}",
        media_type: 'image/png'
      )
    end

    it 'generates the expected args for a non-image resource' do
      expect(described_class.generate_base_resource_request_args(asset, asset.master_resource)).to eq(
        digital_object_uid: asset.uid, src_file_location: "file://#{Rails.root.join('spec', 'fixtures', 'files', 'test.txt')}", options: {}
      )
    end

    it 'generates the expected args for an image resource' do
      expect(described_class.generate_base_resource_request_args(asset, image_resource)).to eq(
        digital_object_uid: asset.uid, src_file_location: "file://#{Rails.root.join('spec', 'fixtures', 'files', 'test.png')}", options: { rotation: '0' }
      )
    end
  end

  describe '.exif_orientation_to_rotation' do
    {
      1 => '0',
      2 => '!0',
      3 => '180',
      4 => '!180',
      5 => '!90',
      6 => '90',
      7 => '!270',
      8 => '270'
    }.each do |exif_orientation, expected_rotation_value|
      it "returns a rotation value of #{expected_rotation_value} for exif orientation #{exif_orientation}" do
        expect(described_class.exif_orientation_to_rotation(exif_orientation)).to eq(expected_rotation_value)
      end
    end
  end

  describe '.src_resource_for_digital_object' do
    context 'when service resource is not present' do
      it 'returns the master resource' do
        expect(described_class.src_resource_for_digital_object(asset)).to eq(asset.master_resource)
      end
    end

    context 'when service resource is present' do
      let(:asset) { FactoryBot.create(:asset, :with_master_resource, :with_service_resource, :skip_resource_request_callbacks) }
      it 'returns the service resource' do
        expect(described_class.src_resource_for_digital_object(asset)).to eq(asset.service_resource)
      end
    end
  end

  describe '.eligible_object?' do
    let(:item) { FactoryBot.create(:item) }

    it 'returns true for an Asset with a valid source resource and no existing access resource' do
      expect(described_class.eligible_object?(asset)).to eq(true)
    end

    it 'returns false for a non-Asset digital object' do
      expect(described_class.eligible_object?(item)).to eq(false)
    end

    context 'for an Asset that already has an access resource' do
      let(:asset) { FactoryBot.create(:asset, :with_master_resource, :with_access_resource, :skip_resource_request_callbacks) }
      it 'returns false' do
        expect(described_class.eligible_object?(asset)).to eq(false)
      end
    end

    context 'for an Asset that has no source resource' do
      before { allow(described_class).to receive(:src_resource_for_digital_object).and_return(nil) }
      it 'returns false' do
        expect(described_class.eligible_object?(asset)).to eq(false)
      end
    end
  end
end
