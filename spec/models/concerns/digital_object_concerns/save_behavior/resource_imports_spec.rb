# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DigitalObjectConcerns::SaveBehavior::ResourceImports do
  let(:digital_object) { FactoryBot.build(:digital_object_test_subclass) }
  let(:test_file_path) { Rails.root.join('spec', 'fixtures', 'files', 'test.txt').to_s }

  context "#process_resource_imports" do
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
          expect(digital_object.resources['test_resource1'].checksum).to eq('urn:sha256:717f2c6ffbd649cd57ecc41ac6130c3b6210f1473303bcd9101a9014551bffb2')
        end

        it "generates file sizes for the created resources" do
          expect(digital_object.resources['test_resource1'].file_size).to eq(23)
        end
      end

      context "track method for regular file location" do
        let(:location) { test_file_path }
        let(:method) { 'track' }

        it "generates checksums for the created resources" do
          expect(digital_object.resources['test_resource1'].checksum).to eq('urn:sha256:717f2c6ffbd649cd57ecc41ac6130c3b6210f1473303bcd9101a9014551bffb2')
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
            checksum: Digest::MD5.hexdigest(blob_content),
            content_type: 'text/plain'
          )
          blob.upload(StringIO.new(blob_content))
          blob
        end
        let(:method) { 'copy' }

        it "generates checksums for the created resources" do
          expect(digital_object.resources['test_resource1'].checksum).to eq('urn:sha256:c72a7eb71263aa3e8936049a925556881c4f9e562dcdc1cae036b11579dfa175')
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

    context "with bad resource import data" do
      before do
        expect(digital_object).to receive(:undo_new_resource_file_copies).and_call_original
      end
      context "performs an undo and raises an error" do
        it "when invalid resource import keys are present" do
          digital_object.assign_resource_imports(
            'resource_imports' => { 'not_a_valid_resource_import_key' => { method: 'copy', location: test_file_path } }
          )
          expect { digital_object.process_resource_imports }.to raise_error(Hyacinth::Exceptions::ResourceImportError)
        end

        it "when an invalid import type is given" do
          digital_object.assign_resource_imports(
            'resource_imports' => { 'test_resource1' => { method: 'banana', location: test_file_path } }
          )
          expect { digital_object.process_resource_imports }.to raise_error(Hyacinth::Exceptions::ResourceImportError)
        end
      end
    end
  end
end
