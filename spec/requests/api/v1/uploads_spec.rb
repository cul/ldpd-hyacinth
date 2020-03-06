# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Uploads API endpoint", type: :request do
  describe 'POST /api/v1/uploads' do
    let(:attributes) do
      {
        blob: {
          filename: 'foo',
          byte_size: 1,
          checksum: 'foo',
          content_type: 'Text/Foo',
          metadata: {}
        }
      }
    end

    context "logged in" do
      before do
        sign_in_user
        post "/api/v1/uploads", params: attributes
      end

      it 'returns 200' do
        expect(response.status).to be 200
      end

      it "returns ActiveStorage direct upload key data" do
        response_json = JSON.parse(response.body).to_json
        expect(response_json).to have_json_path("direct_upload/headers/Content-Type")
        expect(response_json).to have_json_path("direct_upload/url")
        expect(response_json).to have_json_path("key")
        expect(response_json).to have_json_path("signed_id")
      end
    end
  end
end
