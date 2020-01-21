# frozen_string_literal: true

require 'rails_helper'
require 'digest'

RSpec.describe Mutations::CreateAsset, type: :model do
  let(:mutation) { described_class.new(object: authorized_object, context: context) }
  let(:context) { instance_double('GraphQL::Query::Context') }
  let(:authorized_object) { FactoryBot.create(:item, :with_primary_project) }
  let(:authorized_project) { authorized_object.projects.first }
  let(:blob_content) { "This is text to store in a blob" }
  let(:blob_checksum) { Digest::MD5.hexdigest blob_content }

  let(:blob_args) do
    {
      filename: 'blob.xyz',
      byte_size: blob_content.bytesize,
      checksum: blob_checksum,
      content_type: 'text/plain'
    }
  end

  let(:active_storage_blob) do
    blob = ActiveStorage::Blob.create_before_direct_upload!(**blob_args)
    blob.upload(StringIO.new(blob_content))
    blob
  end

  let(:args) do
    {
      parent_id: authorized_object.uid, signed_blob_id: active_storage_blob.signed_id
    }
  end

  describe '#resolve' do
    context 'when asset save fails' do
      let(:ability) { instance_double('Ability') }
      let(:asset) { FactoryBot.create(:asset, parent: authorized_object) }
      let(:predictable_file) { Tempfile.new(['blob', '.xyz']) }
      let(:predictable_file_path) { predictable_file.path }
      let(:storage_adapter) { Hyacinth::Config.resource_storage.primary_storage_adapter }
      let(:predictable_location_uri) { storage_adapter.uri_prefix + predictable_file_path }
      let(:expected_error_message) { "Testing upload deletes" }

      before do
        authorized_object
        expect(mutation).to receive(:initialize_child_asset).and_return(asset)
        expect(context).to receive(:[]).with(:ability).and_return(ability)
        allow(ability).to receive(:authorize!).and_return(true) # not testing auth
        # this failed save should trigger a delete of the newly created asset object
        expect(asset).to receive(:save!).and_raise(expected_error_message)
        expect(Hyacinth::Config.resource_storage).to receive(:generate_new_location_uri).and_return(predictable_location_uri)
        expect(Hyacinth::Config.resource_storage).to receive(:delete).with(predictable_location_uri).and_call_original
        expect(Hyacinth::Config.resource_storage).to receive(:with_writeable).and_wrap_original do |m, *args, &b|
          result = m.call(*args, &b)
          expect(args[0]).to eq(predictable_location_uri)
          expect(Hyacinth::Config.resource_storage.exists?(args[0])).to eq(true)
          result
        end
      end

      after { predictable_file.unlink }
      it 'deletes the uploaded file from storage' do
        expect { mutation.resolve(args) }.to raise_error(expected_error_message)
        expect(Hyacinth::Config.resource_storage.exists?(predictable_location_uri)).to be false
      end
    end
  end
end
