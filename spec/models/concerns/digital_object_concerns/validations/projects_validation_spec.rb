# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DigitalObject::ProjectsValidator, type: :model do
  let(:digital_object) { FactoryBot.build(:digital_object_test_subclass) }
  it "validates that primary is present" do
    digital_object.primary_project = nil
    expect(digital_object).not_to be_valid
  end
  it "validates that primary is not included in other projects" do
    digital_object.other_projects = [digital_object.primary_project]
    expect(digital_object).not_to be_valid
  end
end
