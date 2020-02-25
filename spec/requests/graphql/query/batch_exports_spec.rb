# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Retrieving Batch Exports', type: :request do
  let(:authorized_user) { FactoryBot.create(:user) }
  let!(:batch_export1) { FactoryBot.create(:batch_export, :success, user: authorized_user) }
  let!(:batch_export2) { FactoryBot.create(:batch_export, :success, user: FactoryBot.create(:user, :basic)) }
  let(:request) { graphql query(10, 0) }

  context 'when logged in as a non-administrative used who did not create any of the sample exports' do
    before do
      sign_in_user
      graphql query(10, 0)
    end
    let(:expected_response) do
      %(
        {
          "batchExports": {
            "nodes": [],
            "pageInfo": {
              "hasNextPage": false,
              "hasPreviousPage": false
            },
            "totalCount": 0
          }
        }
      )
    end

    it 'returns none of the exports' do
      expect(response.body).to be_json_eql(expected_response).at_path('data')
    end
  end

  context 'when logged in as a non-administrative used who created one of the sample exports' do
    before do
      login_as authorized_user, scope: :user
      graphql query(10, 0)
    end
    let(:expected_response) do
      %(
        {
          "batchExports": {
            "nodes": [
              {
                "id": "#{batch_export1.id}",
                "createdAt": "#{batch_export1.created_at.iso8601}",
                "downloadPath": "/api/v1/downloads/batch_export/1",
                "duration": 15,
                "exportErrors": [],
                "numberOfRecordsProcessed": 100,
                "searchParams": "{\\"digital_object_type_ssi\\":[\\"item\\"],\\"q\\":null}",
                "status": "success",
                "totalRecordsToProcess": 100,
                "user": {
                  "fullName": "Jane Doe"
                }
              }
            ],
            "pageInfo": {
              "hasNextPage": false,
              "hasPreviousPage": false
            },
            "totalCount": 1
          }
        }
      )
    end

    it 'returns only batch exports created by the logged in user' do
      expect(response.body).to be_json_eql(expected_response).at_path('data')
    end
  end

  context 'when logged in user is an administrator' do
    before do
      sign_in_user as: :administrator
      graphql query(10, 0)
    end
    let(:expected_response) do
      %(
        {
          "batchExports": {
            "nodes": [
              {
                "id": "#{batch_export2.id}",
                "createdAt": "#{batch_export2.created_at.iso8601}",
                "downloadPath": "/api/v1/downloads/batch_export/2",
                "duration": 15,
                "exportErrors": [],
                "numberOfRecordsProcessed": 100,
                "searchParams": "{\\"digital_object_type_ssi\\":[\\"item\\"],\\"q\\":null}",
                "status": "success",
                "totalRecordsToProcess": 100,
                "user": {
                  "fullName": "Basic User"
                }
              },
              {
                "id": "#{batch_export1.id}",
                "createdAt": "#{batch_export1.created_at.iso8601}",
                "downloadPath": "/api/v1/downloads/batch_export/1",
                "duration": 15,
                "exportErrors": [],
                "numberOfRecordsProcessed": 100,
                "searchParams": "{\\"digital_object_type_ssi\\":[\\"item\\"],\\"q\\":null}",
                "status": "success",
                "totalRecordsToProcess": 100,
                "user": {
                  "fullName": "Jane Doe"
                }
              }
            ],
            "pageInfo": {
              "hasNextPage": false,
              "hasPreviousPage": false
            },
            "totalCount": 2
          }
        }
      )
    end

    it 'returns all batch exports created by all users' do
      expect(response.body).to be_json_eql(expected_response).at_path('data')
    end
  end

  context 'paging through results' do
    let(:limit) { 1 }
    let(:offset) { page - 1 }

    before do
      sign_in_user as: :administrator
      graphql minimal_query(limit, offset)
    end

    context "page 1" do
      let(:page) { 1 }
      let(:expected_response) do
        %(
          {
            "batchExports": {
              "nodes": [
                { "id": "#{batch_export2.id}" }
              ],
              "pageInfo": {
                "hasNextPage": true,
                "hasPreviousPage": false
              },
              "totalCount": 2
            }
          }
        )
      end
      it "returns the expected response" do
        expect(response.body).to be_json_eql(expected_response).at_path('data')
      end
    end

    context "page 2" do
      let(:page) { 2 }
      let(:expected_response) do
        %(
          {
            "batchExports": {
              "nodes": [
                { "id": "#{batch_export1.id}" }
              ],
              "pageInfo": {
                "hasNextPage": false,
                "hasPreviousPage": true
              },
              "totalCount": 2
            }
          }
        )
      end
      it "returns the expected response" do
        expect(response.body).to be_json_eql(expected_response).at_path('data')
      end
    end
  end

  def query(limit, offset)
    <<~GQL
      query {
        batchExports(limit: #{limit}, offset: #{offset}) {
          nodes {
            id
            searchParams
            user {
              fullName
            }
            createdAt,
            status
            numberOfRecordsProcessed
            totalRecordsToProcess
            exportErrors
            duration
            downloadPath
          }
          pageInfo {
            hasPreviousPage
            hasNextPage
          }
          totalCount
        }
      }
    GQL
  end

  def minimal_query(limit, offset)
    <<~GQL
      query {
        batchExports(limit: #{limit}, offset: #{offset}) {
          nodes {
            id
          }
          pageInfo {
            hasPreviousPage
            hasNextPage
          }
          totalCount
        }
      }
    GQL
  end
end
