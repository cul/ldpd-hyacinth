require 'rails_helper'

RSpec.describe Hyacinth::Utils::PathUtils do

  describe "uuid methods" do
    let(:uuid) { 'cc092507-6baf-4c81-9cba-ea97cc0b30f2' }
    let(:uuid_pair_tree) { ['cc', '09', '25', '07', '6b', 'af'] }

    context ".uuid_pairtree" do
      it "returns the expected value" do
        expect(described_class.uuid_pairtree(uuid)).to eq(uuid_pair_tree)
      end
    end

    context ".data_file_path_for_uuid" do
      it "returns the expected path" do
        expect(described_class.data_file_path_for_uuid(uuid)).to eq(File.join(HYACINTH['data_directory'], uuid_pair_tree.join('/'), uuid + '.json'))
      end
    end

  end

end
