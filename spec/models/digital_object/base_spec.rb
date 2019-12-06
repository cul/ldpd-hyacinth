# frozen_string_literal: true

require 'rails_helper'

include ActiveSupport::Testing::TimeHelpers

RSpec.describe DigitalObject::Base, type: :model do
  it "cannot be instantiated" do
    expect { described_class.new }.to raise_error(NotImplementedError)
  end
end

RSpec.describe DigitalObject::TestSubclass, type: :model do
  let(:digital_object) { FactoryBot.build(:digital_object_test_subclass) }
  let(:digital_object_with_sample_data) { FactoryBot.build(:digital_object_test_subclass, :with_sample_data) }

  context "a new subclass instance" do
    it "can be instantiated" do
      expect { described_class.new }.not_to raise_error
    end
  end

  context "metadata_resources fields" do
    it "has the expected resources defined" do
      expect(digital_object.resource_attributes.to_a.sort).to eq([:test_resource1, :test_resource2])
    end
  end

  context "metadata_attributes fields" do
    it "has the expected custom fields defined" do
      expect(digital_object.metadata_attributes.keys.sort).to eq(
        [
          :created_at,
          :created_by,
          :custom_field1,
          :custom_field2,
          :digital_object_type,
          :doi,
          :dynamic_field_data,
          :first_preserved_at,
          :first_published_at,
          :identifiers,
          :other_projects,
          :parent_uids,
          :pending_publish_to,
          :pending_unpublish_from,
          :preservation_target_uris,
          :preserved_at,
          :primary_project,
          :publish_entries,
          :serialization_version,
          :state,
          :structured_children,
          :uid,
          :updated_at,
          :updated_by
        ].sort
      )
    end

    it "has the expected frozen fields" do
      expect(digital_object.parent_uids).to be_frozen
      expect(digital_object.publish_entries).to be_frozen
    end

    it "responds to a setter method for a field marked defined with public_writer, but doesn't respond to a setter method for a field not marked with public_writer" do
      expect(digital_object).to respond_to('custom_field2=')
      expect(digital_object).not_to respond_to('custom_field1=')
    end

    it "return the expected default values for a new, unsaved object" do
      freeze_time do
        frozen_datetime = DateTime.current
        expect(digital_object.metadata_attributes.reduce({}) do |hsh, (attribute_name, _attribute)|
          hsh[attribute_name] = digital_object.send(attribute_name)
          hsh
        end).to eq(
          {
            serialization_version: DigitalObject::Base::SERIALIZATION_VERSION,
            uid: nil,
            doi: nil,
            digital_object_type: 'test_subclass',
            state: 'active',
            created_by: nil,
            updated_by: nil,
            created_at: frozen_datetime,
            updated_at: frozen_datetime,
            first_published_at: nil,
            preserved_at: nil,
            first_preserved_at: nil,
            identifiers: Set.new,
            primary_project: nil,
            other_projects: Set.new,
            publish_entries: {},
            parent_uids: Set.new,
            pending_publish_to: [],
            pending_unpublish_from: [],
            structured_children: { 'type' => 'sequence', 'structure' => [] },
            dynamic_field_data: {},
            preservation_target_uris: Set.new,
            custom_field1: 'custom default value 1',
            custom_field2: 'custom default value 2'
          }
        )
      end
    end

    it "returns expected values for a few previously-set fields" do
      expect(digital_object_with_sample_data.dynamic_field_data).to eq({
        'title' => [{
          'non_sort_portion' => 'The',
          'sort_portion' => 'Tall Man and His Hat'
        }]
      })
      expect(digital_object_with_sample_data.custom_field1).to eq('excellent value 1')
      expect(digital_object_with_sample_data.custom_field2).to eq('excellent value 2')
    end
  end

  context "#new_record?" do
    it "returns true for a saved record" do
      expect(digital_object_with_sample_data.new_record?).to eq(true)
    end

    it "returns false for a successfully saved instance" do
      expect(digital_object_with_sample_data.save).to eq(true)
      expect(digital_object_with_sample_data.new_record?).to eq(false)
    end
  end

  context "#digital_object_record" do
    it "returns the underlying digital_object_record" do
      expect(digital_object_with_sample_data.digital_object_record).to be_a(DigitalObjectRecord)
    end
  end

  context "#optimistic_lock_token= and #optimistic_lock_token" do
    let(:token) { SecureRandom.uuid }
    it "can be set and retrieved" do
      digital_object_with_sample_data.optimistic_lock_token = token
      expect(digital_object_with_sample_data.optimistic_lock_token).to eq(token)
    end
  end
  context "validates digital_object_type" do
    it "is valid on construction" do
      expect(digital_object).to be_valid
    end

    it "invalidates unregistered values" do
      digital_object.instance_variable_set :@digital_object_type, digital_object.digital_object_type.reverse
      expect(digital_object).not_to be_valid
      digital_object.instance_variable_set :@digital_object_type, digital_object.digital_object_type.reverse
      expect(digital_object).to be_valid
    end
  end

  context '#parents' do
    let(:parent) { FactoryBot.create(:item) }

    before do
      digital_object_with_sample_data.add_parent_uid(parent.uid)
      digital_object_with_sample_data.save
    end

    it 'returns list of parents' do
      expect(digital_object_with_sample_data.parents.map(&:uid)).to match_array [parent.uid]
    end
  end
end
