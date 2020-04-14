# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DigitalObjectConcerns::AttributeAssignment::ResourceImports do
  let(:digital_object) { FactoryBot.build(:digital_object_test_subclass) }

  before do
    digital_object.assign_resource_imports(
      'resource_imports' => {
        'test_resource1' => {
          method: 'copy',
          location: '/a/b/c'
        },
        'test_resource2' => {
          method: 'track',
          location: '/d/e/f'
        }
      }
    )
  end

  context "#assign_resource_imports" do
    it "creates the expected ResourceImports on the DigitalObject" do
      expect(digital_object.resource_imports['test_resource1']).to be_a(Hyacinth::DigitalObject::ResourceImport)
      expect(digital_object.resource_imports['test_resource1'].method).to eq('copy')
      expect(digital_object.resource_imports['test_resource1'].location).to eq('/a/b/c')

      expect(digital_object.resource_imports['test_resource2']).to be_a(Hyacinth::DigitalObject::ResourceImport)
      expect(digital_object.resource_imports['test_resource2'].method).to eq('track')
      expect(digital_object.resource_imports['test_resource2'].location).to eq('/d/e/f')
    end
  end
end
