# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DigitalObject::RightsFieldsValidator, type: :model, solr: true do
  before { Hyacinth::DynamicFieldsLoader.load_rights_fields!(load_vocabularies: true) }

  describe 'validating rights for DigitalObject::Item' do
    let(:item) { FactoryBot.create(:item) }

    context 'when setting valid rights values' do
      let(:rights) do
        {
          'descriptive_metadata' => [
            {
              'type_of_content' => 'motion_picture'
            }
          ],
          'copyright_ownership' => [
            {
              'name' => {
                'pref_label' => 'Person, Random'
              }
            }
          ],
          'underlying_rights' => [
            {
              'other_underlying_rights' => [
                { 'value' => 'Rights in artistic works' }
              ]
            }
          ],
          'contractual_limitations_restrictions_and_permissions' => [
            { 'option_a' => true }
          ]
        }
      end

      before do
        item.assign_rights({ 'rights' => rights }, false)
      end

      it 'validates successfully' do
        expect(item.valid?).to be true
      end
    end

    context 'when setting value for field that does not exist' do
      let(:rights) do
        {
          'descriptive_metadata' => [
            {
              'type_of_content' => 'motion_picture',
              'new_field' => 'some new value'
            }
          ],
          'author' => 'something',
          'underlying_rights' => [
            {
              'other_underlying_rights' => [
                { 'newer_value' => 'something' }
              ]
            }
          ],
          'contractual_limitations_restrictions_and_permissions' => [
            { 'option_a' => 'something' }
          ]
        }
      end
      let(:expected_errors) do
        {
          'rights.descriptive_metadata[0].new_field': ['is not a valid field'],
          'rights.author': ['is not a valid field'],
          'rights.underlying_rights[0].other_underlying_rights[0].newer_value': ['is not a valid field'],
          'rights.contractual_limitations_restrictions_and_permissions[0].option_a': ['must be a boolean']
        }
      end

      before do
        item.assign_rights({ 'rights' => rights }, false)
      end

      it 'does not validate successfully' do
        expect(item.valid?).to be false
        expect(item.errors.to_hash).to include(expected_errors)
      end
    end
  end

  describe 'validating rights for DigitalObject::Asset' do
    let(:asset) { FactoryBot.create(:asset, :with_main_resource) }

    context 'when setting valid rights values' do
      let(:rights) do
        {
          'asset_access_restriction' => [{
            'affiliation' => [{ 'value' => 'something' }],
            'location' => [{ 'term' => { 'pref_label' => 'Manhattan' } }]
          }]
        }
      end

      before do
        asset.assign_rights({ 'rights' => rights }, false)
      end

      it 'validates successfully' do
        expect(asset.valid?).to be true
      end
    end
  end

  describe 'validating rights for model that should not have rights assigned' do
    let(:test_subclass) { FactoryBot.create(:digital_object_test_subclass) }

    context 'when rights are assigned' do
      before do
        test_subclass.assign_rights('rights' => { 'field_a' => [{ 'field_a_1' => 'something' }] })
      end

      it 'returns an error' do
        expect(test_subclass.valid?).to be false
      end
    end
  end
end
