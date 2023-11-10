require 'rails_helper'

RSpec.describe DigitalObject::Asset, :type => :model do
  describe "#copy_access_copy_to_save_destination" do
    let(:src_path) { '/path/to/src.png' }
    let(:dest_path) { '/path/to/dest.png' }
    let(:expected_file_group) { 'digital-projects' }
    let(:expected_file_permissions) { '0640' }

    context "when the HYACINTH config has values set for access_copy_file_group and access_copy_file_permissions" do
      before do
        stub_const(
          "HYACINTH",
          HYACINTH.dup.merge(
            'access_copy_file_group' => expected_file_group,
            'access_copy_file_permissions' => expected_file_permissions
          )
        )
      end
      it "performs the expected operations" do
        expect(FileUtils).to receive(:cp).with(src_path, dest_path)
        expect(FileUtils).to receive(:chown).with(nil, expected_file_group, dest_path)
        expect(FileUtils).to receive(:chmod).with(expected_file_permissions.to_i(8), dest_path)

        DigitalObject::Asset.new.copy_access_copy_to_save_destination(src_path, dest_path)
      end
    end

    context "when the HYACINTH config has NO values set for access_copy_file_group and access_copy_file_permissions" do
      before do
        stub_const(
          "HYACINTH",
          HYACINTH.dup.merge(
            'access_copy_file_group' => nil,
            'access_copy_file_permissions' => nil
          )
        )
      end
      it "performs the expected operations" do
        expect(FileUtils).to receive(:cp).with(src_path, dest_path)
        expect(FileUtils).not_to receive(:chown)
        expect(FileUtils).not_to receive(:chmod)

        DigitalObject::Asset.new.copy_access_copy_to_save_destination(src_path, dest_path)
      end
    end
  end
end

