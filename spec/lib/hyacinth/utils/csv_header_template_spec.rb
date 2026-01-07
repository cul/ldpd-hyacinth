require 'rails_helper'

RSpec.describe Hyacinth::Utils::CsvHeaderTemplate do

  let(:expected_header_string_df_1) {
    'csv_header_dfg_two-1:' + 'csv_header_dfg_one-1:' + 'csv_header_df_one'
  }
  # NOTE: This makes use of the Collection controlled term in its default state
  # in vanilla hyacinth. As setup in the vanilla config/term_additional_fields.yml,
  # the Collection controlled term has one addtional field, code
  let(:expected_header_string_ct_df_3) {
    ['csv_header_dfg_two-1:' + 'csv_header_dfg_one-1:' + 'csv_header_ct_df_three.uri',
     'csv_header_dfg_two-1:' + 'csv_header_dfg_one-1:' + 'csv_header_ct_df_three.authority',
     'csv_header_dfg_two-1:' + 'csv_header_dfg_one-1:' + 'csv_header_ct_df_three.value',
     'csv_header_dfg_two-1:' + 'csv_header_dfg_one-1:' + 'csv_header_ct_df_three.clio_id']
  }

  let(:expected_array_headers_no_duplicates) {
    ["_digital_object_type.string_key", "_identifiers-1", "_import_file.main.import_location", "_import_file.main.import_type",
     "_import_file.main.original_file_path", "_parent_digital_objects-1.identifier", "_project.string_key",
     "csv_header_dfg_two-1:csv_header_dfg_one-1:csv_header_df_two"]
  }

  let(:expected_array_headers) {
    ["_digital_object_type.string_key", "_identifiers-1", "_import_file.main.import_location", "_import_file.main.import_type",
     "_import_file.main.original_file_path", "_parent_digital_objects-1.identifier", "_project.string_key",
     "csv_header_dfg_two-1:csv_header_df_four",
     "csv_header_dfg_two-1:csv_header_dfg_one-1:csv_header_ct_df_three.authority",
     "csv_header_dfg_two-1:csv_header_dfg_one-1:csv_header_ct_df_three.clio_id",
     "csv_header_dfg_two-1:csv_header_dfg_one-1:csv_header_ct_df_three.uri",
     "csv_header_dfg_two-1:csv_header_dfg_one-1:csv_header_ct_df_three.value",
     "csv_header_dfg_two-1:csv_header_dfg_one-1:csv_header_df_one",
     "csv_header_dfg_two-1:csv_header_dfg_one-1:csv_header_df_two"]
  }

  let(:hash_preload_dfg) {
    Hash[DynamicFieldGroup.includes(:parent_dynamic_field_group).all.map { |dfg| [dfg.id, dfg] }]
    }

  before(:context) do

    @dot_item = DigitalObjectType.find_by(string_key: 'item')
    @dot_asset = DigitalObjectType.find_by(string_key: 'asset')
    @dfg_category = DynamicFieldGroupCategory.create!(id: 2016,
                                                      display_label: 'CSV Header')
    @dfg_2 = DynamicFieldGroup.create!(id: 2017,
                                       string_key: 'csv_header_dfg_two',
                                       display_label: 'Test CSV Header Template DFG 2',
                                       dynamic_field_group_category: @dfg_category)
    @df_4 = @dfg_2.dynamic_fields.create!(id: 2019,
                                          string_key: 'csv_header_df_four',
                                          display_label: 'Test CSV Header Template DF 4',
                                          dynamic_field_type: DynamicField::Type::DATE)

    @dfg_1 = DynamicFieldGroup.create!(id: 2016,
                                       string_key: 'csv_header_dfg_one',
                                       display_label: 'Test CSV Header Template DFG 1',
                                       parent_dynamic_field_group: @dfg_2)
    @df_1 = @dfg_1.dynamic_fields.create!(id: 2016,
                                          string_key: 'csv_header_df_one',
                                          display_label: 'Test CSV Header Template DF 1',
                                          dynamic_field_type: DynamicField::Type::STRING)
    @df_2 = @dfg_1.dynamic_fields.create!(id: 2017,
                                          string_key: 'csv_header_df_two',
                                          display_label: 'Test CSV Header Template DF 2',
                                          dynamic_field_type: DynamicField::Type::STRING)
    @ct_df_3 = @dfg_1.dynamic_fields.create!(id: 2018,
                                             string_key: 'csv_header_ct_df_three',
                                             display_label: 'Test CSV Header Template DF 3 Controlled Term',
                                             dynamic_field_type: DynamicField::Type::CONTROLLED_TERM,
                                             controlled_vocabulary_string_key: 'collection')

    @csv_header_project = Project.create!(id: 2016,
                                          string_key: 'csv_header_project',
                                          display_label: 'Test CSV Header Template Project',
                                          pid_generator: PidGenerator.find_by(namespace: 'test'))
  end

  after(:context) do

    @csv_header_project.destroy
    @dfg_2.destroy
    @dfg_1.destroy
    @df_4.destroy
    @ct_df_3.destroy
    @df_2.destroy
    @df_1.destroy
    @dfg_category.destroy

  end

  # ct = controlled term
  context "#dfg_header_string_non_ct: " do

    it "generates correct header string" do
      expect(Hyacinth::Utils::CsvHeaderTemplate.df_header_string_non_ct(@df_1, hash_preload_dfg)).to eq(expected_header_string_df_1)
    end

  end

  # ct = controlled term
  context "#dfg_header_string_ct: " do

    it "generates correct header string" do
      expect(Hyacinth::Utils::CsvHeaderTemplate.df_header_string_ct(@ct_df_3, hash_preload_dfg)).to eq(expected_header_string_ct_df_3)
    end

  end

  context "#array_dynamic_field_headers: " do

    it "generates correct headers for use case (duplicate dfs, nested dfg, controlled term)" do

      # reset/deleted enabled dynamic fields for this project
      @csv_header_project.enabled_dynamic_fields = []

      @csv_header_project.enabled_dynamic_fields << EnabledDynamicField.new(dynamic_field: @df_1,
                                                                           digital_object_type: @dot_item)
      @csv_header_project.enabled_dynamic_fields << EnabledDynamicField.new(dynamic_field: @df_2,
                                                                           digital_object_type: @dot_asset)
      @csv_header_project.enabled_dynamic_fields << EnabledDynamicField.new(dynamic_field: @df_2,
                                                                           digital_object_type: @dot_item)
      @csv_header_project.enabled_dynamic_fields << EnabledDynamicField.new(dynamic_field: @ct_df_3,
                                                                           digital_object_type: @dot_item)
      @csv_header_project.enabled_dynamic_fields << EnabledDynamicField.new(dynamic_field: @df_4,
                                                                           digital_object_type: @dot_asset)
      @csv_header_project.enabled_dynamic_fields << EnabledDynamicField.new(dynamic_field: @df_4,
                                                                           digital_object_type: @dot_item)
      expect(Hyacinth::Utils::CsvHeaderTemplate.array_dynamic_field_headers(@csv_header_project)).to eq(expected_array_headers)

    end

    it "generates correct headers (no duplicates) with same df enabled twice, for items and assets" do

      # reset/deleted enabled dynamic fields for this project
      @csv_header_project.enabled_dynamic_fields = []

      @csv_header_project.enabled_dynamic_fields << EnabledDynamicField.new(dynamic_field: @df_2,
                                                                          digital_object_type: @dot_item)
      @csv_header_project.enabled_dynamic_fields << EnabledDynamicField.new(dynamic_field: @df_2,
                                                                          digital_object_type: @dot_asset)
      expect(Hyacinth::Utils::CsvHeaderTemplate.array_dynamic_field_headers(@csv_header_project)).to eq(expected_array_headers_no_duplicates)

    end

  end
end
