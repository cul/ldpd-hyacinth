# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DigitalObject::ResourceImportValidator do
  let(:validator) { described_class.new }
  let(:digital_object) { FactoryBot.build(:digital_object_test_subclass) }
  let(:test_file_path) { Rails.root.join('spec', 'fixtures', 'files', 'test.txt').to_s }

  context "validating a DigitalObject with good resource import data" do
    before do
      digital_object.assign_resource_imports(
        'resource_imports' => {
          'test_resource1' => {
            method: 'copy',
            location: test_file_path
          }
        }
      )
      validator.validate(digital_object)
    end

    it 'does not add any errors' do
      expect(digital_object.errors).to be_blank
    end
  end

  context "validating a DigitalObject with bad resource import data" do
    context "when an invalid resource import key is present" do
      before do
        digital_object.assign_resource_imports(
          'resource_imports' => {
            'what_an_invalid_resource_name' => {
              method: 'copy',
              location: test_file_path
            }
          }
        )
        validator.validate(digital_object)
      end

      it 'adds the expected error to the object being validated' do
        expect(digital_object.errors.messages).to eq(resource_imports: ['Invalid resource import keys: what_an_invalid_resource_name'])
      end
    end

    context "when a valid resource import key has an invalid value" do
      before do
        digital_object.assign_resource_imports(
          'resource_imports' => {
            'test_resource1' => {
              method: 'banana',
              location: test_file_path
            }
          }
        )
        validator.validate(digital_object)
      end

      it 'adds the expected error to the object being validated' do
        expect(digital_object.errors.messages).to eq('resource_imports.test_resource1': ['Invalid resource import: test_resource1'])
      end
    end

    context "when a resource import's file cannot be found" do
      before do
        digital_object.assign_resource_imports(
          'resource_imports' => {
            'test_resource1' => {
              method: 'copy',
              location: '/this/file/does/not/exist'
            }
          }
        )
        validator.validate(digital_object)
      end

      it 'adds the expected error to the object being validated' do
        expect(digital_object.errors.messages).to eq('resource_imports.test_resource1': ['Unreadable file for resource import: test_resource1'])
      end
    end
  end
end
