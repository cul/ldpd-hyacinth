# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Digital Object Resources API endpoint", type: :request do
  let(:authorized_object) do
    FactoryBot.create(:asset, :with_primary_project, :with_master_resource)
  end
  let(:resource_name) { 'master' }
  let(:empty_resource_name) { 'service' }
  let(:authorized_project) { authorized_object.primary_project }

  describe 'GET /api/v1/digital_objects/:id/resources/:resource_name/download' do
    include_examples 'requires user to have correct permissions' do
      let(:request) do
        get "/api/v1/digital_objects/#{authorized_object.uid}/resources/#{resource_name}/download"
      end
    end

    context "logged in" do
      before do
        sign_in_project_contributor to: [:read_objects], project: authorized_project
      end

      context "for a model-configured resource that currently has no file" do
        before do
          get "/api/v1/digital_objects/#{authorized_object.uid}/resources/#{empty_resource_name}/download"
        end

        it "returns 404" do
          expect(response.status).to be 404
        end
      end

      context "for a model-configured resource that has a file" do
        before do
          get "/api/v1/digital_objects/#{authorized_object.uid}/resources/#{resource_name}/download"
        end
        it 'returns 200' do
          expect(response.status).to eq 200
        end

        context "headers" do
          {
            'Content-Type' => 'text/plain',
            'Content-Disposition' => "attachment; ; filename*=utf-8''test.txt",
            'Content-Length' => '23'
          }.each do |header, expected_value|
            it "has the correct value for header: #{header}" do
              expect(response.header[header]).to eq(expected_value)
            end
          end

          it 'has the correct value for header: Last-Modified' do
            expect(response.header['Last-Modified']).to eq(authorized_object.updated_at.httpdate)
          end
        end

        it "returns the expected content" do
          expect(response.body).to eq("What a great test file!")
        end
      end
    end
  end
end
