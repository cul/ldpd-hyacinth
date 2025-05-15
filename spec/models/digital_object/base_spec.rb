require 'rails_helper'

RSpec.describe DigitalObject::Base, :type => :model do

  let(:sample_item_digital_object_data) {
    dod = JSON.parse( fixture('sample_digital_object_data/new_item.json').read )
    dod['identifiers'] = ['item.' + SecureRandom.uuid] # random identifer to avoid collisions
    dod
  }

  let(:sample_asset_digital_object_data) {
    dod = JSON.parse( fixture('sample_digital_object_data/new_asset.json').read )
    dod['identifiers'] = ['asset.' + SecureRandom.uuid] # random identifer to avoid collisions

    file_path = File.join(fixture_path(), '/files/lincoln.jpg')

    # Manually override import_file settings in the dummy fixture
    dod['import_file'] = {
      'import_type' => DigitalObject::Asset::IMPORT_TYPE_INTERNAL,
      'import_path' => file_path,
      'original_file_path' => file_path
    }

    dod
  }
  let(:sample_group_digital_object_data) {
    dod = JSON.parse( fixture('sample_digital_object_data/new_group.json').read )
    dod['identifiers'] = ['group.' + SecureRandom.uuid] # random identifer to avoid collisions
    dod
  }
  let(:second_sample_group_digital_object_data) {
    dod = JSON.parse( fixture('sample_digital_object_data/new_group.json').read )
    dod['identifiers'] = ['group.' + SecureRandom.uuid] # random identifer to avoid collisions
    dod
  }

  describe "#initialize" do
    it "has a default dynamic_field_data value of {}" do
      digital_object = DigitalObject::Item.new()
      expect(digital_object.dynamic_field_data).to eq({})
    end
  end

  describe "#created_at" do
    it "returns a date" do
      new_item = DigitalObjectType.get_model_for_string_key(sample_item_digital_object_data['digital_object_type']['string_key']).new()
      new_item.set_digital_object_data(sample_item_digital_object_data, false)
      new_item.save
      datetime_today = DateTime.now.in_time_zone('UTC')
      expect(new_item.created_at.in_time_zone('UTC').strftime("%m/%d/%Y")).to eq(datetime_today.strftime("%m/%d/%Y"))
      new_item.destroy
    end
  end

  describe "#updated_at" do
    it "returns a date" do
      new_item = DigitalObjectType.get_model_for_string_key(sample_item_digital_object_data['digital_object_type']['string_key']).new()
      new_item.set_digital_object_data(sample_item_digital_object_data, false)
      new_item.save
      datetime_today = DateTime.now.in_time_zone('UTC')
      expect(new_item.updated_at.in_time_zone('UTC').strftime("%m/%d/%Y")).to eq(datetime_today.strftime("%m/%d/%Y"))
      new_item.destroy
    end
  end

  describe "#set_digital_object_data" do

    describe "raises exceptions for invalid data" do
      it "raises an exception for an object that references a parent digital object identifier that doesn't exist" do
        # Set parent identifier for new item data
        sample_item_digital_object_data['parent_digital_objects'] = [
          {
            'identifier' => 'this is an identifier that definitely does not exist --- ' + SecureRandom.uuid
          }
        ]

        new_item_with_parent_group = DigitalObjectType.get_model_for_string_key(sample_item_digital_object_data['digital_object_type']['string_key']).new()
        expect {
          new_item_with_parent_group.set_digital_object_data(sample_item_digital_object_data, false)
        }.to raise_error(Hyacinth::Exceptions::ParentDigitalObjectNotFoundError)
      end

      it "raises an exception for an object that references a project that doesn't exist" do
        # Set project for new item data
        sample_item_digital_object_data['project'] = {
          'string_key' => 'aaaaaaaaaaa_does_not_exist_aaaaaaaaaaa'
        }

        new_item = DigitalObjectType.get_model_for_string_key(sample_item_digital_object_data['digital_object_type']['string_key']).new()
        expect {
          new_item.set_digital_object_data(sample_item_digital_object_data, false)
        }.to raise_error(Hyacinth::Exceptions::ProjectNotFoundError)
      end

      it "raises an exception for an object that references a publish target that doesn't exist" do
        # Set publish target for new item data
        sample_item_digital_object_data['publish_targets'] = [
          {
            'string_key' => 'zzzzzzzzzz_does_not_exist_zzzzzzzzzz'
          }
        ]

        new_item = DigitalObjectType.get_model_for_string_key(sample_item_digital_object_data['digital_object_type']['string_key']).new()
        expect {
          new_item.set_digital_object_data(sample_item_digital_object_data, false)
        }.to raise_error(Hyacinth::Exceptions::PublishTargetNotFoundError)
      end

      it "raises an exception for a new object that references a pid that cannot be resolved to an existing Fedora object" do
        new_item = DigitalObjectType.get_model_for_string_key(sample_item_digital_object_data['digital_object_type']['string_key']).new()
        sample_item_digital_object_data['pid'] = 'definitely:does_not_exist_zzzzz'
        expect {
          new_item.set_digital_object_data(sample_item_digital_object_data, false)
        }.to raise_error(Hyacinth::Exceptions::AssociatedFedoraObjectNotFoundError)
      end

      context "raises an exception for malformed controlled term field data" do
        it "rejects controlled term data that lacks both uri and value fields" do
          new_item = DigitalObjectType.get_model_for_string_key(sample_item_digital_object_data['digital_object_type']['string_key']).new()
          sample_item_digital_object_data['dynamic_field_data']['collection'] = [
            {
              "collection_term" => {
                "custom_field" => "zzz",
              }
            }
          ]
          expect {
            new_item.set_digital_object_data(sample_item_digital_object_data, false)
          }.to raise_error(Hyacinth::Exceptions::MalformedControlledTermFieldValue)
        end
      end

      context "raises an exception for prohibited temp term field data" do
        # These tests assume that these controlled vocabulary and dynamic field groups were
        # already set up by the hyacinth:setup:core_records rake task.
        let(:controlled_vocabulary) { ControlledVocabulary.find_by(string_key: 'collection') }
        before do
          if controlled_vocabulary
            @original_temp_flag = controlled_vocabulary.prohibit_temp_terms
            controlled_vocabulary.prohibit_temp_terms = true
            controlled_vocabulary.save
          end
        end
        after do
          if controlled_vocabulary
            controlled_vocabulary.prohibit_temp_terms = @original_temp_flag
            controlled_vocabulary.save
          end
        end
        it "rejects controlled term data that lacks a uri and has a value field" do
          new_item = DigitalObjectType.get_model_for_string_key(sample_item_digital_object_data['digital_object_type']['string_key']).new()
          sample_item_digital_object_data['dynamic_field_data']['collection'] = [
            {
              "collection_term" => {
                "value" => "prohibited_temp_terms_value",
              }
            }
          ]
          expect {
            new_item.set_digital_object_data(sample_item_digital_object_data, false)
          }.to raise_error(Hyacinth::Exceptions::MalformedControlledTermFieldValue)
        end
      end
    end

    describe "for any valid DigitalObject" do
      it "sets @mint_reserved_doi_before_save to true when {'mint_reserved_doi' => true} is present in the digital object data" do
        item = DigitalObjectType.get_model_for_string_key(sample_item_digital_object_data['digital_object_type']['string_key']).new()
        item.set_digital_object_data(sample_item_digital_object_data.merge({'mint_reserved_doi' => true}), false)
        expect(item.mint_reserved_doi_before_save).to eq(true)

        # Reset the value
        item.mint_reserved_doi_before_save = false

        # Verify that it also works with a string (for CSV import scenarios)
        item.set_digital_object_data(sample_item_digital_object_data.merge({'mint_reserved_doi' => 'TRUE'}), false)
        expect(item.mint_reserved_doi_before_save).to eq(true)
      end
    end

    describe "for DigitalObject::Group" do

      it "works for a Group that does not have a parent object" do
        group = DigitalObjectType.get_model_for_string_key(sample_group_digital_object_data['digital_object_type']['string_key']).new()
        group.set_digital_object_data(sample_group_digital_object_data, false)

        expect(group).to be_instance_of(DigitalObject::Group)
        expect(group.identifiers).to eq(sample_group_digital_object_data['identifiers'])
        expect(group.project.string_key).to eq('test')
        expect(group.publish_targets.map{|publish_target| publish_target.publish_target_field('string_key')}.sort).to eq(['test_publish_target_1'])
        expect(group.dynamic_field_data).to eq(sample_group_digital_object_data['dynamic_field_data'])

        expect(group.created_by).to be_nil # Because we didn't set created_by
        expect(group.updated_by).to be_nil # Because we didn't set modified_by
      end

      it "works for a Group that references a parent Group" do
        # Create parent Group
        new_group = DigitalObjectType.get_model_for_string_key(sample_group_digital_object_data['digital_object_type']['string_key']).new()
        new_group.set_digital_object_data(sample_group_digital_object_data, false)
        new_group.save

        parent_group_pid = new_group.pid
        parent_group_identifier = new_group.identifiers.select{|identifier| identifier != parent_group_pid}.first

        # Set parent identifier for new Group data
        second_sample_group_digital_object_data['parent_digital_objects'] = [
          {
            'identifier' => parent_group_identifier
          }
        ]

        # Create child Group that references parent Group
        new_group_with_parent_group = DigitalObjectType.get_model_for_string_key(second_sample_group_digital_object_data['digital_object_type']['string_key']).new()
        new_group_with_parent_group.set_digital_object_data(second_sample_group_digital_object_data, false)

        expect(new_group_with_parent_group).to be_instance_of(DigitalObject::Group)
        expect(new_group_with_parent_group.identifiers).to eq(second_sample_group_digital_object_data['identifiers'])
        expect(new_group_with_parent_group.parent_digital_object_pids).to eq([parent_group_pid])
        expect(new_group_with_parent_group.project.string_key).to eq('test')
        expect(new_group_with_parent_group.publish_targets.map{|publish_target| publish_target.publish_target_field('string_key')}.sort).to eq(['test_publish_target_1'])
        expect(new_group_with_parent_group.dynamic_field_data).to eq(second_sample_group_digital_object_data['dynamic_field_data'])

        expect(new_group_with_parent_group.created_by).to be_nil # Because we didn't set created_by
        expect(new_group_with_parent_group.updated_by).to be_nil # Because we didn't set modified_by
      end
    end

    describe "for DigitalObject::Item" do

      it "works for an Item that does not have a parent object" do
        item = DigitalObjectType.get_model_for_string_key(sample_item_digital_object_data['digital_object_type']['string_key']).new()
        item.set_digital_object_data(sample_item_digital_object_data, false)

        expect(item).to be_instance_of(DigitalObject::Item)
        expect(item.identifiers).to eq(sample_item_digital_object_data['identifiers'])
        expect(item.project.string_key).to eq('test')
        expect(item.publish_targets.map{|publish_target| publish_target.publish_target_field('string_key')}.sort).to eq(['test_publish_target_1', 'test_publish_target_2'])
        expect(item.dynamic_field_data).to eq(sample_item_digital_object_data['dynamic_field_data'])

        expect(item.created_by).to be_nil # Because we didn't set created_by
        expect(item.updated_by).to be_nil # Because we didn't set modified_by
      end

      it "works for an Item that references a parent Group" do
        # Create parent Group
        new_group = DigitalObjectType.get_model_for_string_key(sample_group_digital_object_data['digital_object_type']['string_key']).new()
        new_group.set_digital_object_data(sample_group_digital_object_data, false)
        new_group.save

        parent_group_pid = new_group.pid
        parent_group_identifier = new_group.identifiers.select{|identifier| identifier != parent_group_pid}.first

        # Set parent identifier for new item data
        sample_item_digital_object_data['parent_digital_objects'] = [
          {
            'identifier' => parent_group_identifier
          }
        ]

        # Create child Item that references parent Group
        new_item_with_parent_group = DigitalObjectType.get_model_for_string_key(sample_item_digital_object_data['digital_object_type']['string_key']).new()
        new_item_with_parent_group.set_digital_object_data(sample_item_digital_object_data, false)

        expect(new_item_with_parent_group).to be_instance_of(DigitalObject::Item)
        expect(new_item_with_parent_group.identifiers).to eq(sample_item_digital_object_data['identifiers'])
        expect(new_item_with_parent_group.parent_digital_object_pids).to eq([parent_group_pid])
        expect(new_item_with_parent_group.project.string_key).to eq('test')
        expect(new_item_with_parent_group.publish_targets.map{|publish_target| publish_target.publish_target_field('string_key')}.sort).to eq(['test_publish_target_1', 'test_publish_target_2'])
        expect(new_item_with_parent_group.dynamic_field_data).to eq(sample_item_digital_object_data['dynamic_field_data'])

        expect(new_item_with_parent_group.created_by).to be_nil # Because we didn't set created_by
        expect(new_item_with_parent_group.updated_by).to be_nil # Because we didn't set modified_by
      end
    end

    describe "for DigitalObject::Asset" do

      it "works for an Asset that does not have a parent object" do
        asset = DigitalObjectType.get_model_for_string_key(sample_asset_digital_object_data['digital_object_type']['string_key']).new()
        asset.set_digital_object_data(sample_asset_digital_object_data, false)

        expect(asset).to be_instance_of(DigitalObject::Asset)
        expect(asset.identifiers).to eq(sample_asset_digital_object_data['identifiers'])
        expect(asset.project.string_key).to eq('test')
        expect(asset.publish_targets.map{|publish_target| publish_target.publish_target_field('string_key')}.sort).to eq(['test_publish_target_2'])
        expect(asset.dynamic_field_data).to eq(sample_asset_digital_object_data['dynamic_field_data'])

        expect(asset.created_by).to be_nil # Because we didn't set created_by
        expect(asset.updated_by).to be_nil # Because we didn't set modified_by

        expect(asset.restricted_size_image).to eq(true)
        expect(asset.restricted_onsite).to eq(true)
      end

      it "works for an Asset that references a parent Item" do
        # Create parent Item
        new_item = DigitalObjectType.get_model_for_string_key(sample_item_digital_object_data['digital_object_type']['string_key']).new()
        new_item.set_digital_object_data(sample_item_digital_object_data, false)
        new_item.save

        parent_item_pid = new_item.pid
        parent_item_identifier = new_item.identifiers.select{|identifier| identifier != parent_item_pid}.first

        # Set parent identifier for new asset data
        sample_asset_digital_object_data['parent_digital_objects'] = [
          {
            'identifier' => parent_item_identifier
          }
        ]

        # Create child Asset that references parent Item
        new_asset_with_parent_item = DigitalObjectType.get_model_for_string_key(sample_asset_digital_object_data['digital_object_type']['string_key']).new()
        new_asset_with_parent_item.set_digital_object_data(sample_asset_digital_object_data, false)

        expect(new_asset_with_parent_item).to be_instance_of(DigitalObject::Asset)
        expect(new_asset_with_parent_item.identifiers).to eq(sample_asset_digital_object_data['identifiers'])
        expect(new_asset_with_parent_item.parent_digital_object_pids).to eq([parent_item_pid])
        expect(new_asset_with_parent_item.project.string_key).to eq('test')
        expect(new_asset_with_parent_item.publish_targets.map{|publish_target| publish_target.publish_target_field('string_key')}.sort).to eq(['test_publish_target_2'])
        expect(new_asset_with_parent_item.dynamic_field_data).to eq(sample_asset_digital_object_data['dynamic_field_data'])

        expect(new_asset_with_parent_item.created_by).to be_nil # Because we didn't set created_by
        expect(new_asset_with_parent_item.updated_by).to be_nil # Because we didn't set modified_by
      end
    end
  end

  describe "#save" do
    it "saves the object, which can then be found using DigitalObject::Base.find" do
        item = DigitalObjectType.get_model_for_string_key(sample_item_digital_object_data['digital_object_type']['string_key']).new()
        item.set_digital_object_data(sample_item_digital_object_data, false)
        item.save
        expect(DigitalObject::Base.find(item.pid).pid).to eq(item.pid)
    end

    it 'calls before_save' do
      item = DigitalObjectType.get_model_for_string_key(sample_item_digital_object_data['digital_object_type']['string_key']).new()
      expect(item).to receive(:before_save)
      item.set_digital_object_data(sample_item_digital_object_data, false)
      item.save
    end

    context 'when before_save sets an error' do
      it 'preserves the error and does not call persist_to_stores' do
        item = DigitalObjectType.get_model_for_string_key(sample_item_digital_object_data['digital_object_type']['string_key']).new()
        allow(item).to receive(:before_save) {
          item.errors.add(:some_error, 'This is an error message!')
        }
        item.set_digital_object_data(sample_item_digital_object_data, false)
        expect(item.save).to eq(false)
        expect(item.errors).to include(:some_error)
      end
    end

    context 'when Hyacinth::Exceptions::DataciteErrorResponse thrown' do
      it 'preserves the error' do
        item = DigitalObjectType.get_model_for_string_key(sample_item_digital_object_data['digital_object_type']['string_key']).new()
        allow(item).to receive(:mint_and_store_doi).and_raise Hyacinth::Exceptions::DataciteErrorResponse
        item.set_digital_object_data(sample_item_digital_object_data, false)
        item.mint_reserved_doi_before_save = true
        item.save
        expect(item.errors.messages).to include(:datacite)
      end
    end

    context 'when Hyacinth::Exceptions::DataciteConnectionError thrown' do
      it 'preserves the error' do
        item = DigitalObjectType.get_model_for_string_key(sample_item_digital_object_data['digital_object_type']['string_key']).new()
        allow(item).to receive(:mint_and_store_doi).and_raise Hyacinth::Exceptions::DataciteConnectionError
        item.set_digital_object_data(sample_item_digital_object_data, false)
        item.mint_reserved_doi_before_save = true
        item.save
        expect(item.errors.messages).to include(:datacite)
      end
    end

    context 'when Hyacinth::Exceptions::DoiExists thrown' do
      it 'preserves the error' do
        item = DigitalObjectType.get_model_for_string_key(sample_item_digital_object_data['digital_object_type']['string_key']).new()
        allow(item).to receive(:mint_and_store_doi).and_raise Hyacinth::Exceptions::DoiExists
        item.set_digital_object_data(sample_item_digital_object_data, false)
        item.mint_reserved_doi_before_save = true
        item.save
        expect(item.errors.messages).to include(:datacite)
      end
    end

    context "when saving item, updates solr index" do
      let(:item) do
        item = DigitalObjectType.get_model_for_string_key(sample_item_digital_object_data['digital_object_type']['string_key']).new()
        item.set_digital_object_data(sample_item_digital_object_data, false)
        item.save
        item
      end

      subject {
        Hyacinth::Utils::SolrUtils.solr.get('select', :params => { q: "pid:\"#{item.pid}\""})["response"]["docs"].first
      }

      it "returns a document with valid fields" do
        expect(subject).to include(
          "title_ssm" => ["The Catcher in the Rye"],
          "number_of_ordered_child_digital_object_pids_ssm" => ["0"],
          "hyacinth_type_ssm" => ["item"],
          "state_ssm" => ["A"],
          "digital_object_type_display_label_ssm" => ["Item"],
          "project_display_label_ssm" => ["Test"],
          "dc_type_ssm" => ["InteractiveResource"],
        )
      end

      it "returns a document with two enabled publish targets" do
        expect(subject["enabled_publish_target_pid_ssm"].count).to eql 2
      end
    end

    context "for Assets, serizlizes the restricted_size_image property to Fedora" do
      let (:asset) {
        asset = DigitalObjectType.get_model_for_string_key(sample_asset_digital_object_data['digital_object_type']['string_key']).new()
        asset.set_digital_object_data(sample_asset_digital_object_data, false)
        asset
      }

      it "by adding RELS-EXT restriction property with value SIZE_RESTRICTION_LITERAL_VALUE when restricted_size_image is true" do
        asset.restricted_size_image = true
        asset.save
        expect(asset.fedora_object.relationships(:restriction)).to include(DigitalObject::Asset::SIZE_RESTRICTION_LITERAL_VALUE)
      end

      it "by removing RELS-EXT restriction property with value SIZE_RESTRICTION_LITERAL_VALUE when restricted_size_image is false" do
        asset.restricted_size_image = false
        asset.save
        expect(asset.fedora_object.relationships(:restriction)).not_to include(DigitalObject::Asset::SIZE_RESTRICTION_LITERAL_VALUE)
      end
    end

    context "for Assets, serizlizes the restricted_onsite property to Fedora" do
      let (:asset) {
        asset = DigitalObjectType.get_model_for_string_key(sample_asset_digital_object_data['digital_object_type']['string_key']).new()
        asset.set_digital_object_data(sample_asset_digital_object_data, false)
        asset
      }

      it "by adding RELS-EXT restriction property with value ONSITE_RESTRICTION_LITERAL_VALUE when restricted_size_image is true" do
        asset.restricted_onsite = true
        asset.save
        expect(asset.fedora_object.relationships(:restriction)).to include(DigitalObject::Asset::ONSITE_RESTRICTION_LITERAL_VALUE)
      end

      it "by removing RELS-EXT restriction property with value ONSITE_RESTRICTION_LITERAL_VALUE when restricted_size_image is false" do
        asset.restricted_onsite = false
        asset.save
        expect(asset.fedora_object.relationships(:restriction)).not_to include(DigitalObject::Asset::ONSITE_RESTRICTION_LITERAL_VALUE)
      end
    end

    it "can create a new DigitalObject for an existing Fedora object that isn't being tracked by Hyacinth, and preserves identifiers, parents and publish targets from that Fedora object" do
        existing_parent_object_pid = 'test:existing_parent_object'
        existing_parent_object = Collection.new(:pid => existing_parent_object_pid)
        existing_parent_object.save

        first_publish_target_result = DigitalObject::Base.search(
          {
            'per_page' => 1,
            'fl' => 'pid',
            'fq' => { 'hyacinth_type_sim' => [{ 'equals' => 'publish_target' }] }
          },
          nil,
          {}
        )

        publish_target = DigitalObject::Base.find(first_publish_target_result['results'].first['pid'])
        publish_target_fedora_object = publish_target.fedora_object

        existing_object_pid = 'test:existingobject'
        existing_object_identifier = 'custom_identifier'
        content_aggregator = ContentAggregator.new(:pid => existing_object_pid)
        content_aggregator.datastreams['DC'].dc_identifier = [existing_object_identifier]
        content_aggregator.add_relationship(:cul_member_of, existing_parent_object.internal_uri)
        content_aggregator.add_relationship(:publisher, publish_target_fedora_object.internal_uri)
        content_aggregator.save

        expect(content_aggregator.pid).to eq(existing_object_pid) # New Fedora object has been assigned given pid
        expect(DigitalObject::Base.find_by_pid(existing_object_pid)).to eq(nil) # Hyacinth is not aware of any object with given pid

        # Create object with given pid
        sample_item_digital_object_data['pid'] = existing_object_pid
        item = DigitalObjectType.get_model_for_string_key(sample_item_digital_object_data['digital_object_type']['string_key']).new()
        item.set_digital_object_data(sample_item_digital_object_data, false)
        expect(item.pid).to eq(existing_object_pid) # pid should be set for the item

        # Save item, which should then refer to the existing Fedora object
        item.save

        expect(item.fedora_object).to eq(content_aggregator)
        expect(item.fedora_object.datastreams['DC'].dc_identifier.include?(existing_object_identifier)).to be(true)
        expect(item.parent_digital_object_pids.include?(existing_parent_object_pid)).to be(true)
        expect(item.publish_targets.map{ |pub_target| pub_target.pid }.include?(publish_target.pid)).to be(true)
    end

    context "when publishing after saving" do
      let(:item) {
        item = DigitalObjectType.get_model_for_string_key(sample_item_digital_object_data['digital_object_type']['string_key']).new()
        item.set_digital_object_data(sample_item_digital_object_data, false)
        item.publish_after_save = true
        item
      }

      context "when HYACINTH[:publish_enabled] equals false" do
        let(:original_publish_enabled_value) { HYACINTH[:publish_enabled] }
        before {
          original_publish_enabled_value # invoke let variable to set it
          HYACINTH[:publish_enabled] = false
        }
        after {
          HYACINTH[:publish_enabled] = original_publish_enabled_value
        }
        it "does not save or publish and adds an error" do
          item.publish_after_save = true
          # verify that save methods and publish methods aren't called
          expect(item).not_to receive(:before_save)
          expect(item).not_to receive(:persist_to_stores)
          expect(item).not_to receive(:publish)
          expect(item.save).to eq(false)
          # expect an error
          expect(item.errors[:publish]).to be_present
        end
      end

      it "mints id before saving" do
        expect(item).to receive(:mint_and_store_doi).with("draft")
        item.save
      end

      it "calls publish method" do
        allow(item).to receive(:mint_and_store_doi).with("draft")
        expect(item).to receive(:publish)
        item.save
      end

      it "sets first_published_at date" do
        allow(item).to receive(:mint_and_store_doi).with("draft")
        item.save
        expect(item.first_published_at).to be_within(10.seconds).of(Time.current)
        expect(item.instance_variable_get(:@db_record).first_published_at).to be_within(10.seconds).of(Time.current)
      end
    end
  end

  describe '.get_class_for_fedora_object' do
    let!(:fedora_object) do
      fedora_object = cmodel.new
      fedora_object.datastreams['DC'].dc_type = model.const_get('VALID_DC_TYPES').clone
      fedora_object
    end

    subject { DigitalObject::Base.get_class_for_fedora_object(fedora_object) }

    context 'with a GenericResource' do
      let(:cmodel) { GenericResource }
      let(:model) { DigitalObject::Asset }

      it { is_expected.to be model }
    end

    context 'with a ContentAggregator' do
      let(:cmodel) { ContentAggregator }
      let(:model) { DigitalObject::Item }

      it { is_expected.to be model }
    end

    context 'with a BagAggregator' do
      let(:cmodel) { Collection }
      let(:model) { DigitalObject::Group }

      it { is_expected.to be model }
    end

    context 'with a FileSystem' do
      let(:cmodel) { Collection }
      let(:model) { DigitalObject::FileSystem }

      it { is_expected.to be model }
    end

    context 'with a PublishTarget' do
      let(:cmodel) { Concept }
      let(:model) { DigitalObject::PublishTarget }

      it { is_expected.to be model }
    end
  end

  describe '#internal_fields' do
    let(:item) {
      item = DigitalObjectType.get_model_for_string_key(sample_item_digital_object_data['digital_object_type']['string_key']).new()
      item.set_digital_object_data(sample_item_digital_object_data, false)
      item.db_record.created_at = Time.now
      item.db_record.updated_at = Time.now
      item
    }
    let(:expected_internal_field_values) do
      {
        'project.string_key' => 'test'
      }
    end
    it 'includes project fields' do
      expect(item.send :internal_fields).to include(expected_internal_field_values)
    end
  end

  describe '#perform_derivative_processing' do
    it 'defaults to false for a non-Asset digital object' do
      item = DigitalObject::Item.new
      expect(item.perform_derivative_processing).to eq(false)
    end

    it 'can be set and the set value can be retrieved' do
      item = DigitalObject::Item.new
      item.perform_derivative_processing = true
      expect(item.perform_derivative_processing).to eq(true)
    end
  end

  describe "#execute_publish_action_for_target" do
    let(:sample_publish_target_digital_object_data) {
      JSON.parse( fixture('sample_digital_object_data/new_publish_target.json').read )
    }

    let(:publish_target) do
      publish_target = DigitalObjectType.get_model_for_string_key(
        sample_publish_target_digital_object_data['digital_object_type']['string_key']
      ).new
      publish_target.set_digital_object_data(sample_publish_target_digital_object_data, false)
      publish_target.save
      publish_target
    end

    context "handling doi errors" do
      [
        Hyacinth::Exceptions::DataciteErrorResponse,
        Hyacinth::Exceptions::DataciteConnectionError,
        Hyacinth::Exceptions::MissingDoi
      ].each do |error_class|
        context "when a publish operation throws a #{error_class.name}" do
          it 'rescues the exception and stores the message in the digital object errors' do
            item = DigitalObjectType.get_model_for_string_key(sample_item_digital_object_data['digital_object_type']['string_key']).new
            allow(publish_target).to receive(:publish_digital_object).and_raise(error_class)
            item.execute_publish_action_for_target(:publish, publish_target, true)
            expect(item.errors.messages).to include(:datacite)
          end
        end

        context "when an unpublish operation throws a #{error_class.name}" do
          it 'rescues the exception and stores the message in the digital object errors' do
            item = DigitalObjectType.get_model_for_string_key(sample_item_digital_object_data['digital_object_type']['string_key']).new
            allow(publish_target).to receive(:unpublish_digital_object).and_raise(error_class)
            item.execute_publish_action_for_target(:unpublish, publish_target, true)
            expect(item.errors.messages).to include(:datacite)
          end
        end
      end
    end
  end
end
