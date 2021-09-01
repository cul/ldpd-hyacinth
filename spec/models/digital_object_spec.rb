# frozen_string_literal: true

require 'rails_helper'
include ActiveSupport::Testing::TimeHelpers

RSpec.describe DigitalObject, type: :model do
  # Since the DigitalObject class can't be instantiated, we'll perform all instance tests on a minimal subclass instance.
  let(:instance) { FactoryBot.build(:digital_object_test_subclass) }

  describe '#new' do
    it 'fails when the class being instantiated is this base class' do
      expect { described_class.new }.to raise_error(NotImplementedError)
    end

    it 'succeeds when a subclass is instantiated' do
      expect { instance }.not_to raise_error
    end
  end

  describe 'a basic subclass instance' do
    context "metadata_resources fields" do
      it "has the expected resources defined" do
        expect(instance.resource_attribute_names.to_a.sort).to eq([:test_resource1, :test_resource2])
      end
    end

    context "metadata_attributes fields" do
      let(:expected_fields) do
        [
          :custom_field1,
          :custom_field2,
          :descriptive_metadata,
          :identifiers,
          :other_projects,
          :preservation_target_uris,
          :primary_project,
          :rights,
          :title
        ].sort
      end
      it "has the expected custom fields defined" do
        expect(instance.metadata_attributes.keys.sort).to eq(expected_fields)
      end
    end

    it "has the expected frozen fields" do
      expect(instance.parents).to be_frozen
      expect(instance.children).to be_frozen
    end

    it "responds to a setter method for a field marked defined with public_writer, but doesn't respond to a setter method for a field not marked with public_writer" do
      expect(instance).to respond_to('custom_field2=')
      expect(instance).not_to respond_to('custom_field1=')
    end

    context "for a new, unsaved object" do
      let(:instance) { DigitalObject::TestSubclass.new }
      let(:expected_values) do
        {
          custom_field1: 'custom default value 1',
          custom_field2: 'custom default value 2',
          descriptive_metadata: {},
          identifiers: Set.new,
          primary_project: nil,
          other_projects: Set.new,
          preservation_target_uris: Set.new,
          rights: {},
          title: nil
        }
      end

      it "returns the expected default values for metadata_attributes" do
        freeze_time do
          expect(instance.metadata_attributes.each_with_object({}) do |(attribute_name, _attribute), hsh|
            hsh[attribute_name] = instance.send(attribute_name)
            hsh
          end).to eq(expected_values)
        end
      end

      it "returns the expected default values for flag fields" do
        expect(instance.mint_doi).to eq(false)
      end
    end

    context "#optimistic_lock_token= and #optimistic_lock_token" do
      let(:token) { SecureRandom.uuid }
      it "can be set and retrieved" do
        instance.optimistic_lock_token = token
        expect(instance.optimistic_lock_token).to eq(token)
      end
    end

    describe '#save' do
      include_context 'with stubbed search adapters'
      it 'saves without errors' do
        result = instance.save
        expect(instance.errors).to be_empty
        expect(result).to eq(true)
      end

      context 'first save (i.e. create)' do
        it 'creates a file at metadata_location_uri' do
          instance.save
          expect(Hyacinth::Config.metadata_storage.exists?(instance.metadata_location_uri)).to eq(true)
        end

        it 'generates a uid' do
          expect(instance.uid).to eq(nil)
          instance.save
          expect(instance.uid).to be_present
        end

        it 'generates a metadata_location_uri' do
          expect(instance.metadata_location_uri).to eq(nil)
          instance.save
          expect(instance.metadata_location_uri).to be_present
        end

        it 'generates a backup_metadata_location_uri' do
          expect(instance.backup_metadata_location_uri).to eq(nil)
          instance.save
          expect(instance.backup_metadata_location_uri).to be_present
        end

        it 'has a different value for the metadata_location_uri and the backup_metadata_location_uri' do
          instance.save
          expect(instance.metadata_location_uri).not_to eq(instance.backup_metadata_location_uri)
        end

        it 'generates an optimistic_lock_token' do
          expect(instance.optimistic_lock_token).to eq(nil)
          instance.save
          expect(instance.optimistic_lock_token).to be_present
        end
      end

      context 'second save (i.e. update)' do
        before { instance.save }
        let!(:original_uid) { instance.uid }
        let!(:original_metadata_location_uri) { instance.metadata_location_uri }
        let!(:original_backup_metadata_location_uri) { instance.backup_metadata_location_uri }
        let!(:original_optimistic_lock_token) { instance.optimistic_lock_token }

        it 'writes to the file at metadata_location_uri' do
          instance.save
          expect(Hyacinth::Config.metadata_storage.exists?(instance.metadata_location_uri)).to eq(true)
        end

        it 'copies the previous metadata to the file at backup_metadata_location_uri' do
          previous_metadata = Hyacinth::Config.metadata_storage.read(instance.metadata_location_uri)
          instance.identifiers << 'some new indentifier'
          instance.save
          backed_up_metadata = Hyacinth::Config.metadata_storage.read(instance.backup_metadata_location_uri)
          current_metadata = Hyacinth::Config.metadata_storage.read(instance.metadata_location_uri)

          expect(backed_up_metadata).to eq(previous_metadata)
          expect(backed_up_metadata).not_to eq(current_metadata)
        end

        it 'retains the same uid' do
          instance.save
          expect(instance.uid).to eq(original_uid)
        end

        it 'retains the same metadata_location_uri' do
          instance.save
          expect(instance.metadata_location_uri).to eq(original_metadata_location_uri)
        end

        it 'retains the same backup_metadata_location_uri' do
          instance.save
          expect(instance.backup_metadata_location_uri).to eq(original_backup_metadata_location_uri)
        end

        it 'generates a new optimistic_lock_token' do
          instance.save
          expect(instance.optimistic_lock_token).not_to eq(original_optimistic_lock_token)
        end

        context 'on save failure, rolls back the metadata file to the previous state (from backup file)' do
          let(:identifier_to_add) { 'some new indentifier' }
          before do
            # Make sure that we encounter an error during the next save, which will trigger a rollback
            original_write_fields_to_metadata_storage_method = instance.method(:write_fields_to_metadata_storage)
            allow(instance).to receive(:write_fields_to_metadata_storage) do
              # Call original method
              original_write_fields_to_metadata_storage_method.call
              # Ensure that after method is called, file contains new identifier
              current_metadata = Hyacinth::Config.metadata_storage.read(instance.metadata_location_uri)
              expect(JSON.parse(current_metadata)['metadata']['identifiers']).to include(identifier_to_add)
              # And then raise an exception to trigger a rollback (and restore metadata from backup file)
              raise StandardError, 'This will trigger a rollback!'
            end
          end

          it 'works as expected' do
            instance.identifiers << identifier_to_add
            expect { instance.save }.to raise_error(StandardError, 'This will trigger a rollback!')
            current_metadata = Hyacinth::Config.metadata_storage.read(instance.metadata_location_uri)
            # After error, latest version of metadata file is restored to the backup, so it won't contain the new identifier
            expect(JSON.parse(current_metadata)['metadata']['identifiers']).not_to include(identifier_to_add)
          end
        end

        context 'on save failure, rolls back resources to state before successful processing of a resource_import' do
          let(:test_file_path) { Rails.root.join('spec', 'fixtures', 'files', 'test.txt').to_s }
          let(:resource_import_data) do
            {
              'resource_imports' => {
                'test_resource1' => {
                  method: 'copy',
                  location: test_file_path
                }
              }
            }
          end
          before do
            # Set up some resources
            instance.assign_resource_imports(resource_import_data)
            instance.save
            # Prepare new resource imports
            instance.assign_resource_imports(resource_import_data)

            # Make sure that we encounter an error during the next save, which will trigger a rollback
            original_write_fields_to_metadata_storage_method = instance.method(:write_fields_to_metadata_storage)
            original_test_resource1 = instance.resources['test_resource1']
            allow(instance).to receive(:write_fields_to_metadata_storage) do
              # Call original method
              original_write_fields_to_metadata_storage_method.call
              # Ensure that after method is called, digital object has new, different resource instance
              expect(instance.resources['test_resource1']).not_to equal(original_test_resource1)
              # And then raise an exception to trigger a rollback (and restore metadata from backup file)
              raise StandardError, 'This will trigger a rollback!'
            end
          end

          it 'has the same, original resource instances stored in the resources hash' do
            original_test_resource1 = instance.resources['test_resource1']
            expect { instance.save }.to raise_error(StandardError, 'This will trigger a rollback!')
            expect(instance.resources['test_resource1']).to equal(original_test_resource1)
          end
        end
      end
    end

    describe 'metadata and resource attribute persistence and retrieval' do
      include_context 'with stubbed search adapters'
      let(:instance) { FactoryBot.build(:digital_object_test_subclass, :with_ascii_title, :with_test_resource1) }
      it 'persists metadata attributes and can retrieve them when a record is loaded' do
        instance.save
        expect(DigitalObject.find_by_uid(instance.uid).title.dig('value', 'sort_portion')).to eq('Tall Man and His Hat')
      end

      it 'persists resource attributes and can retrieve them when a record is loaded' do
        instance.save
        expect(DigitalObject.find_by_uid(instance.uid).resources['test_resource1']).to be_present
      end
    end

    describe '#destroy' do
      include_context 'with stubbed search adapters'
      let(:instance) do
        dobj = FactoryBot.create(:digital_object_test_subclass)
        dobj.parents_to_add << parent
        dobj.save
        dobj
      end
      let(:parent) do
        FactoryBot.create(:digital_object_test_subclass)
      end

      context 'successful destroy' do
        before do
          expect(instance).not_to receive(:index)
          expect(instance).to receive(:deindex)
          expect(instance.destroy)
        end

        it 'deletes the file at metadata_location_uri' do
          expect(Hyacinth::Config.metadata_storage.exists?(instance.metadata_location_uri)).to eq(false)
        end

        it 'disconnects the object from its parent' do
          expect(instance.parents).to be_empty
          parent.reload
          expect(parent.children).to be_empty
        end
      end

      context 'when object has children' do
        before do
          instance.children_to_add << FactoryBot.create(:digital_object_test_subclass)
          expect(instance.save).to eq(true)
          expect(instance.children).to be_present
        end
        it 'fails to destroy' do
          expect(instance.destroy).to eq(false)
          expect(instance.errors.size).to eq(1)
          expect(instance.errors[:children]).to eq(['Cannot destroy digital object because it has children.  Disconnect or delete the child digital objects first.'])
        end
      end
    end

    describe '#index' do
      include_context 'with stubbed search adapters'
      it 'delegates indexing behavior to digital_object_search_adapter' do
        expect(search_adapter).to receive(:index)
        instance.index
      end
    end

    describe '#deindex' do
      include_context 'with stubbed search adapters'
      it 'delegates de-indexing behavior to digital_object_search_adapter' do
        expect(search_adapter).to receive(:remove)
        instance.deindex
      end
    end

    describe 'saving and retrieving serialized metadata attributes' do
      include_context 'with stubbed search adapters'
      let(:identifiers) { Set.new(['some-identifier', 'some-other-identifier']) }
      it 'successfully saves and retrieves a metadata attribute' do
        expect(instance.metadata_attributes.key?(:identifiers)).to eq(true)
        instance.identifiers = identifiers
        instance.save
        expect(DigitalObject.find_by_uid!(instance.uid).identifiers).to eq(identifiers)
      end
    end

    describe '#generate_display_label' do
      context 'has title data' do
        let(:instance) { FactoryBot.build(:digital_object_test_subclass, :with_ascii_title) }
        it do
          expect(instance.generate_display_label).to eql('The Tall Man and His Hat')
        end
      end
      context 'with no title data' do
        let(:instance) { FactoryBot.build(:digital_object_test_subclass) }
        it do
          expect(instance.generate_display_label).to eql(instance.uid)
        end
      end
    end
    describe "#valid?" do
      describe 'title validations' do
        let(:valid_with_sort_portion) { { 'sort_portion' => 'Test Fixture' } }
        let(:invalid_with_whitespace_sort_portion) { { 'sort_portion' => ' ' } }
        let(:invalid_without_sort_portion) { { 'non_sort_portion' => 'A ' } }
        let(:valid_blank) { {} }
        it 'is valid with only a sort portion' do
          instance.assign_attributes('title' => { 'value' => valid_with_sort_portion })
          expect(instance).to be_valid
        end
        it 'is valid with an empty title hash' do
          instance.assign_attributes('title' => valid_blank)
          expect(instance).to be_valid
        end
        it 'is valid with a nil title' do
          instance.assign_attributes('title' => nil)
          expect(instance).to be_valid
        end
        it 'is invalid when title hash is present but sort_portion is blank' do
          instance.assign_attributes('title' => { 'value' => invalid_with_whitespace_sort_portion })
          expect(instance).not_to be_valid
          instance.assign_attributes('title' => { 'value' => invalid_without_sort_portion })
          expect(instance).not_to be_valid
        end
      end
    end
    # TODO: Add tests for timestamps created_at, updated_at, preserved_at, etc.
  end
end
