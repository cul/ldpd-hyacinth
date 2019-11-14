require 'rails_helper'

RSpec.describe DigitalObjectConcerns::DigitalObjectData::Setters::Projects do
  let(:projects) { Set[FactoryBot.create(:project), FactoryBot.create(:project, :legend_of_lincoln)] }
  let(:different_projects) { Set[FactoryBot.create(:project, :myth_of_minken)] }
  let(:digital_object) { FactoryBot.build(:digital_object_test_subclass) }
  let(:digital_object_data_with_projects) do
    { 'projects' => projects.map { |p| { 'string_key' => p.string_key } } }
  end
  let(:digital_object_data_with_different_projects) do
    { 'projects' => different_projects.map { |p| { 'string_key' => p.string_key } } }
  end

  context "#set_projects" do
    it "sets the projects each time it's called" do
      expect(digital_object.projects).to be_blank
      digital_object.set_projects(digital_object_data_with_projects)
      expect(digital_object.projects).to eq(projects)
      digital_object.set_projects(digital_object_data_with_different_projects)
      expect(digital_object.projects).to eq(different_projects)
    end
  end
end
