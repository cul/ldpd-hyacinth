require 'rails_helper'

RSpec.describe Hyacinth::Utils::PathUtils do
  describe "uuid methods" do
    let(:uuid) { 'cc092507-6baf-4c81-9cba-ea97cc0b30f2' }
    let(:uuid_pair_tree) { ['cc', '09', '25', '07'] }
    let(:legacy_six_depth_uuid_pair_tree) { ['cc', '09', '25', '07', '6b', 'af'] }

    context ".uuid_pairtree" do
      it "returns the expected value" do
        expect(described_class.uuid_pairtree(uuid)).to eq(uuid_pair_tree)
      end
    end

    context ".data_file_path_for_uuid" do
      it "returns the expected path" do
        expect(described_class.data_file_path_for_uuid(uuid)).to eq(File.join(HYACINTH[:digital_object_data_directory], legacy_six_depth_uuid_pair_tree.join('/'), uuid, uuid + '.json'))
      end
    end

    context ".legacy_six_depth_uuid_pairtree" do
      it "returns the expected value" do
        expect(described_class.legacy_six_depth_uuid_pairtree(uuid)).to eq(legacy_six_depth_uuid_pair_tree)
      end
    end

    context ".relative_resource_directory_path_for_uuid" do
      it "returns the expected path" do
        expect(described_class.relative_resource_directory_path_for_uuid(uuid)).to eq(File.join(uuid_pair_tree.join('/'), uuid))
      end

      it "returns the expected path, and only has one period before the extension even if the caller supplies an extension value that starts with a period" do
        expect(
          described_class.relative_resource_directory_path_for_uuid(uuid)
        ).to eq(File.join(uuid_pair_tree.join('/'), uuid))
      end
    end

    context ".relative_resource_file_path_for_uuid" do
      let(:suffix) { '-main' }
      let(:extension) { 'png' }
      let(:extension_that_starts_with_period) { ".#{extension}" }
      it "returns the expected path" do
        expect(described_class.relative_resource_file_path_for_uuid(uuid, suffix, extension)).to eq(File.join(uuid_pair_tree.join('/'), uuid, uuid + suffix + '.' + extension))
      end

      it "returns the expected path, and only has one period before the extension even if the caller supplies an extension value that starts with a period" do
        expect(
          described_class.relative_resource_file_path_for_uuid(uuid, suffix, extension_that_starts_with_period)
        ).to eq(File.join(uuid_pair_tree.join('/'), uuid, uuid + suffix + '.' + extension))
      end
    end
  end
end
