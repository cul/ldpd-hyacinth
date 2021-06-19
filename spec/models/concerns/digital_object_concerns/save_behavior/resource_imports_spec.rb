# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DigitalObjectConcerns::ResourceImports do
  let(:digital_object) { FactoryBot.build(:digital_object_test_subclass) }
  let(:test_file_path) { Rails.root.join('spec', 'fixtures', 'files', 'test.txt').to_s }
  let(:location) { test_file_path }
  let(:method) { 'copy' }

  describe "#process_resource_imports" do
    context "successful single file import" do
      before do
        digital_object.assign_resource_imports(
          'resource_imports' => {
            'test_resource1' => {
              method: method,
              location: location
            }
          }
        )
        digital_object.process_resource_imports
      end

      context "copy method for regular file location" do
        let(:location) { test_file_path }
        let(:method) { 'copy' }

        it "generates checksums for the created resources" do
          expect(digital_object.resources['test_resource1'].checksum).to eq('sha256:717f2c6ffbd649cd57ecc41ac6130c3b6210f1473303bcd9101a9014551bffb2')
        end

        it "generates file sizes for the created resources" do
          expect(digital_object.resources['test_resource1'].file_size).to eq(23)
        end
      end

      context "track method for regular file location" do
        let(:location) { test_file_path }
        let(:method) { 'track' }

        it "generates checksums for the created resources" do
          expect(digital_object.resources['test_resource1'].checksum).to eq('sha256:717f2c6ffbd649cd57ecc41ac6130c3b6210f1473303bcd9101a9014551bffb2')
        end

        it "generates file sizes for the created resources" do
          expect(digital_object.resources['test_resource1'].file_size).to eq(23)
        end
      end

      context "copy method for ActiveStorage::Blob location" do
        let(:location) do
          blob_content = "Run, don't walk from...the blob!"
          blob = ActiveStorage::Blob.create_before_direct_upload!(
            filename: 'blobfile.txt',
            byte_size: blob_content.bytesize,
            checksum: Digest::MD5.base64digest(blob_content),
            content_type: 'text/plain'
          )
          blob.upload(StringIO.new(blob_content))
          blob
        end
        let(:method) { 'copy' }

        it "generates checksums for the created resources" do
          expect(digital_object.resources['test_resource1'].checksum).to eq('sha256:c72a7eb71263aa3e8936049a925556881c4f9e562dcdc1cae036b11579dfa175')
        end

        it "generates file sizes for the created resources" do
          expect(digital_object.resources['test_resource1'].file_size).to eq(32)
        end
      end
    end

    context "successful multiple file import" do
      let(:another_test_file_path) { Rails.root.join('spec', 'fixtures', 'files', 'test2.txt').to_s }

      before do
        digital_object.assign_resource_imports(
          'resource_imports' => {
            'test_resource1' => {
              method: 'copy',
              location: test_file_path
            },
            'test_resource2' => {
              method: 'track',
              location: another_test_file_path
            }
          }
        )
        digital_object.process_resource_imports
      end

      it "creates multiple resources" do
        expect(digital_object.resources['test_resource1']).to be_a(Hyacinth::DigitalObject::Resource)
        expect(digital_object.resources['test_resource2']).to be_a(Hyacinth::DigitalObject::Resource)
      end
    end
  end

  describe '#finalize_resource_imports' do
    let(:test_file_path) { Rails.root.join('spec', 'fixtures', 'files', 'test.txt').to_s }
    let(:resource_import_data) do
      {
        'resource_imports' => {
          'test_resource1' => {
            method: method,
            location: location
          }
        }
      }
    end
    before do
      # Set up some resources
      digital_object.assign_resource_imports(resource_import_data)
      digital_object.save
      # Prepare new resource imports with same field name to ensure presence of old_resources during save
      digital_object.assign_resource_imports(resource_import_data)
      expect(digital_object).to receive(:finalize_resource_imports).and_call_original
    end

    it "deletes the previous resource's file, clears the resource import value, and clears the old_resource for this resource name" do
      old_resource = digital_object.resources['test_resource1']
      expect(Hyacinth::Config.resource_storage).to receive(:delete).with(old_resource.location)
      digital_object.save
      expect(digital_object.resources['test_resource1']).not_to equal(old_resource)
      expect(digital_object.resource_imports['test_resource1']).to eq(nil)
      expect(digital_object.old_resources['test_resource1']).to eq(nil)
    end
  end
end
