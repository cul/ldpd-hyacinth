require 'rails_helper'

RSpec.describe Hyacinth::Utils::FedoraUtils::DatastreamMigrations do
  describe '#clone_to_dsid' do
    let(:repository) { Rubydora.connect(Rails.application.config_for(:fedora)) }
    let(:asset_digital_object_data) do
      dod = JSON.parse( fixture('sample_digital_object_data/new_asset.json').read )
      file_path = File.join(fixture_path(), '/sample_upload_files/lincoln.jpg')
      # Manually override import_file settings in the dummy fixture
      dod['import_file'] = {
        'import_type' => DigitalObject::Asset::IMPORT_TYPE_INTERNAL,
        'import_path' => file_path,
        'original_file_path' => file_path
      }
      dod
    end
    let(:asset) do
      ### Create asset ###
      asset_digital_object_data['identifiers'] = []
      asset_digital_object_data['dynamic_field_data']['title'] = [
        {
          "title_sort_portion" => "Asset 0",
          "title_non_sort_portion" => "The"
        }
      ]

      new_asset = DigitalObjectType.get_model_for_string_key(asset_digital_object_data['digital_object_type']['string_key']).new()
      new_asset.set_digital_object_data(asset_digital_object_data, false)
      new_asset.save
      new_asset
    end

    shared_examples "clones a datastream" do 
      it "sets up ds properties correctly" do
        result = Hyacinth::Utils::FedoraUtils::DatastreamMigrations.clone_to_dsid(asset.pid, source_dsid, target_dsid)
        puts result
        expect(result[:status]).to be true
        obj = repository.find(asset.pid)
        src_versions = obj.datastreams[source_dsid].versions.sort_by { |b| b.lastModifiedDate }
        target_versions = obj.datastreams[target_dsid].versions.sort_by { |b| b.lastModifiedDate }
        first_src_profile = src_versions.first.profile.symbolize_keys
        first_target_profile = target_versions.first.profile.symbolize_keys
        expect(first_src_profile.delete(:dsVersionID)).to start_with(source_dsid)
        expect(first_target_profile.delete(:dsVersionID)).to start_with(target_dsid)
        keys_to_delete = [:dsCreateDate]
        keys_to_delete << :dsLocation unless src_versions.first.external?
        keys_to_delete.each { |k| first_src_profile.delete(k); first_target_profile.delete(k) }
        expect(first_target_profile).to eql(first_src_profile)
        result = Hyacinth::Utils::FedoraUtils::DatastreamMigrations.verify_identical_content(asset.pid, source_dsid, target_dsid)
        puts result
        expect(result[:status]).to be true
      end
    end
    context "external datastream" do
      let(:source_dsid) { 'content' }
      let(:target_dsid) { 'legacyContent' }
      include_examples "clones a datastream"
    end
    context "managed datastream" do
      let(:source_dsid) { 'descMetadata' }
      let(:target_dsid) { 'legacyDescMetadata' }
      before do
        asset.save_datastreams
        asset.save
      end
      include_examples "clones a datastream"
    end
  end
end