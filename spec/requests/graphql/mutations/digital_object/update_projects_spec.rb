# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::DigitalObject::UpdateProjects, type: :request do
  include_context 'with stubbed search adapters'
  let(:primary_project) { FactoryBot.create(:project) }
  let(:secondary_project) { FactoryBot.create(:project) }
  let(:tertiary_project) { FactoryBot.create(:project) }
  let(:other_projects_set) { Set.new([secondary_project, tertiary_project]) }
  let(:authorized_item) { FactoryBot.create(:item, primary_project: primary_project, other_projects: other_projects_set) }
  let(:nonexistent_project_string_key) { "nonexistent_project" }

  context 'when updating other_projects' do
    let(:variables) do
      {
        input: {
          id: authorized_item.uid,
          primaryProject: {
            stringKey: primary_project.string_key
          },
          otherProjects: [
            { stringKey: tertiary_project.string_key }
          ]
        }
      }
    end

    include_examples 'a basic user with no abilities is not authorized to perform this request' do
      let(:request) { graphql query, variables }
    end

    context "when logged in user has appropriate permissions" do
      before do
        sign_in_project_contributor to: :update_objects, project: primary_project
        graphql query, variables
      end

      it "return a single item with the expected other projects" do
        expect(response.body).to be_json_eql("\"#{tertiary_project.string_key}\"").at_path('data/updateProjects/digitalObject/otherProjects/0/stringKey')
      end

      context "when user errors are present" do
        let(:variables) do
          {
            input: {
              id: authorized_item.uid,
              primaryProject: {
                stringKey: primary_project.string_key
              },
              otherProjects: [
                { stringKey: nonexistent_project_string_key }
              ]
            }
          }
        end

        it "returns a null digital object and an error of the expected format at the expected path" do
          expect(response.body).to be_json_eql(%(null)).at_path('data/updateProjects/digitalObject')
          expect(response.body).to be_json_eql(%(
            "missing projects for string keys [\\"#{nonexistent_project_string_key}\\"]"
          )).at_path('data/updateProjects/userErrors/0/message')
        end
      end
    end
  end

  context 'when updating primary_project' do
    let(:variables) do
      {
        input: {
          id: authorized_item.uid,
          primaryProject: {
            stringKey: secondary_project.string_key
          },
          otherProjects: [
            { stringKey: primary_project.string_key }
          ]
        }
      }
    end

    include_examples 'a basic user with no abilities is not authorized to perform this request' do
      let(:request) { graphql query, variables }
    end

    context "when logged in user has appropriate permissions" do
      before do
        sign_in_project_contributor to: [:update_objects, :create_objects, :delete_objects], project: [primary_project, secondary_project]
        graphql query, variables
      end

      it "return a single item with the expected project relationships" do
        expect(response.body).to be_json_eql("\"#{secondary_project.string_key}\"").at_path('data/updateProjects/digitalObject/primaryProject/stringKey')
        expect(response.body).to be_json_eql("\"#{primary_project.string_key}\"").at_path('data/updateProjects/digitalObject/otherProjects/0/stringKey')
      end

      it "changes the primary project" do
        expect(authorized_item.reload.primary_project.string_key).to eql(secondary_project.string_key)
      end

      context "but primary project does not exist" do
        let(:variables) do
          {
            input: {
              id: authorized_item.uid,
              primaryProject: {
                stringKey: nonexistent_project_string_key
              },
              otherProjects: [
                { stringKey: primary_project.string_key }
              ]
            }
          }
        end
        it "returns a null digital object and an error of the expected format at the expected path" do
          expect(response.body).to be_json_eql(%(null)).at_path('data/updateProjects/digitalObject')
          expect(response.body).to be_json_eql(%(
            "missing projects for string keys [\\"#{nonexistent_project_string_key}\\"]"
          )).at_path('data/updateProjects/userErrors/0/message')
        end
        it "does not change the primary project" do
          expect(authorized_item.reload.primary_project.string_key).to eql(primary_project.string_key)
        end
      end
    end
  end

  def query
    <<~GQL
      mutation ($input: UpdateProjectsInput!) {
        updateProjects(input: $input) {
          digitalObject {
            id
            primaryProject { stringKey }
            otherProjects { stringKey }
          }
          userErrors {
            message
            path
          }
        }
      }
    GQL
  end
end
