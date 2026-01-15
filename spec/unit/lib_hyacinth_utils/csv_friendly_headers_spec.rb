require 'rails_helper'

context 'Hyacinth::Utils::CsvFriendlyHeaders' do
  describe ".hyacinth_headers_to_friendly_headers" do

    # it "translates headers properly" do
    #   df_and_dfg_string_keys_to_display_labels = {
    #     'title' => 'Title',
    #     'title_sort_portion' => 'Sort Portion',
    #     'title_non_sort_portion' => 'Non-Sort Portion',
    #     'name' => 'Name',
    #     'name_term' => 'Term',
    #     'name_role' => 'Role',
    #     'name_role_term' => 'Term',
    #   }

    #   controlled_vocabulary_field_string_keys_to_controlled_vocabulary_string_keys = {
    #     'name_term' => 'name'
    #   }

    #   hyacinth_headers_to_expected_friendly_labels = {
    #     '_pid' => 'PID',
    #     '_project.string_key' => 'Project > String Key',
    #     '_project.pid' => 'Project > PID',
    #     '_publish_targets-1.string_key' => 'Publish Target 1 > String Key',
    #     '_publish_targets-1.pid' => 'Publish Target 1 > PID',
    #     '_parent_digital_objects-1.identifier' => 'Parent Digital Object 1 > Identifier',
    #     '_parent_digital_objects-1.pid' => 'Parent Digital Object 1 > PID',
    #     '_identifiers-1' => 'Identifier 1',
    #     '_asset_data.checksum' => 'Asset Data > Checksum',
    #     '_asset_data.file_size_in_bytes' => 'Asset Data > File Size In Bytes',
    #     '_asset_data.filesystem_location' => 'Asset Data > Filesystem Location',
    #     '_asset_data.original_file_path' => 'Asset Data > Original File Path',
    #     '_asset_data.original_filename' => 'Asset Data > Original Filename',
    #     'title-1:title_sort_portion' => 'Title 1 > Sort Portion',
    #     'title-1:title_non_sort_portion' => 'Title 1 > Non-Sort Portion',
    #     'name-1:name_term.value' => 'Name 1 > Term > Value',
    #     'name-1:name_term.authority' => 'Name 1 > Term > Authority',
    #     'name-1:name_term.uri' => 'Name 1 > Term > URI',
    #     'name-1:name_term.name_type' => 'Name 1 > Term > Name Type',
    #     'name-1:name_role-1:name_role_term.value' => 'Name 1 > Role 1 > Term > Value',
    #     'name-1:name_role-1:name_role_term.authority' => 'Name 1 > Role 1 > Term > Authority',
    #     'name-1:name_role-1:name_role_term.uri' => 'Name 1 > Role 1 > Term > URI',
    #   }

    #   expect(
    #     Hyacinth::Utils::CsvFriendlyHeaders.hyacinth_headers_to_friendly_headers(hyacinth_headers_to_expected_friendly_labels.keys, df_and_dfg_string_keys_to_display_labels, controlled_vocabulary_field_string_keys_to_controlled_vocabulary_string_keys)
    #   ).to eq(hyacinth_headers_to_expected_friendly_labels.values)
    # end
  end
end
