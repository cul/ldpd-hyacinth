# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DigitalObjectConcerns::AttributeAssignment::Projects do
  let(:primary_project) { FactoryBot.create(:project) }
  let(:different_primary_project) { FactoryBot.create(:project, :legend_of_lincoln) }
  let(:aggregator_projects) { Set[FactoryBot.create(:project, :myth_of_minken)] }
  let(:digital_object) { FactoryBot.build(:digital_object_test_subclass) }
  let(:digital_object_data_with_projects) do
    {
      'primary_project' => primary_project,
      'other_projects' => aggregator_projects.map { |p| { 'string_key' => p.string_key } }
    }
  end
  let(:digital_object_data_with_different_projects) do
    {
      'primary_project' => different_primary_project,
      'other_projects' => aggregator_projects.map { |p| { 'string_key' => p.string_key } }
    }
  end

  context "#assign_projects" do
    it "sets the projects each time it's called" do
      expect(digital_object.projects).to be_blank
      digital_object.assign_projects(digital_object_data_with_projects)
      expect(digital_object.projects).to eq([primary_project] + aggregator_projects.to_a)
      digital_object.assign_projects(digital_object_data_with_different_projects)
      expect(digital_object.projects).to eq([different_primary_project] + aggregator_projects.to_a)
    end
  end
end
