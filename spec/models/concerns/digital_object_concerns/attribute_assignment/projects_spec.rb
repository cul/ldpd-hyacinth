# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DigitalObjectConcerns::AttributeAssignment::Projects do
  let(:digital_object) { FactoryBot.build(:digital_object_test_subclass) }
  let(:original_primay_project) { digital_object.primary_project }

  let(:different_primary_project) { FactoryBot.create(:project) }
  let(:another_different_primary_project) { FactoryBot.create(:project) }
  let(:other_projects) { [FactoryBot.create(:project, :myth_of_minken)] }
  let(:nonexistent_project_string_key) { "nonexistent_project" }
  let(:digital_object_data_with_projects) do
    {
      'primary_project' => different_primary_project,
      'other_projects' => other_projects.map { |p| { 'string_key' => p.string_key } }
    }
  end
  let(:digital_object_data_with_different_projects) do
    {
      'primary_project' => another_different_primary_project,
      'other_projects' => other_projects.map { |p| { 'string_key' => p.string_key } }
    }
  end
  let(:digital_object_data_with_bad_project_keys) do
    {
      'primary_project' => another_different_primary_project,
      'other_projects' => [{ 'string_key' => nonexistent_project_string_key }]
    }
  end

  describe "#assign_projects" do
    it "sets the projects each time it's called" do
      digital_object.assign_projects(digital_object_data_with_projects)
      expect(digital_object.projects).to eq([different_primary_project] + other_projects)

      digital_object.assign_projects(digital_object_data_with_different_projects)
      expect(digital_object.projects).to eq([another_different_primary_project] + other_projects)
    end
    context "with a non-existent other project string_key" do
      let(:expected_error) { Hyacinth::Exceptions::NotFound }
      it "raises expected error" do
        expect { digital_object.assign_projects(digital_object_data_with_bad_project_keys) }.to raise_error(expected_error)
      end
    end
  end
end
