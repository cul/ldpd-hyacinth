require 'rails_helper'

RSpec.describe 'Api::V2::PublishTargets', type: :request do
  let!(:publish_target) { FactoryBot.create(:publish_target, string_key: 'publish_targets_spec_a') }
  let(:json) { JSON.parse(response.body) }

  # Tests don't run in transactions so we have to clean up any records created here
  after do
    DigitalObjectRecord.where(pid: 'publish_targets_spec:1').destroy_all
    PublishTarget.where('string_key LIKE ?', 'publish_targets_spec_%').destroy_all
  end

  context 'when signed in as a non-admin user' do
    before { login_as(FactoryBot.create(:non_admin_user)) }

    it 'denies access' do
      get api_v2_publish_targets_path
      expect(response).to have_http_status(:forbidden)
    end
  end

  context 'when signed in as an admin user' do
    before { request_test_sign_in_admin_user }

    describe 'GET /api/v2/publish_targets' do
      it 'lists publish targets' do
        get api_v2_publish_targets_path
        expect(response).to have_http_status(:ok)
        expect(json['publishTargets'].map { |target| target['stringKey'] }).to include('publish_targets_spec_a')
      end
    end

    describe 'POST /api/v2/publish_targets' do
      let(:project) { Project.find_by!(string_key: 'test') }

      it 'creates a publish target and assigns it to the given projects' do
        post api_v2_publish_targets_path, as: :json, params: {
          publishTarget: {
            stringKey: 'publish_targets_spec_b', displayLabel: 'Publish Target B', publishUrl: 'http://localhost/publish', apiKey: 'test_api_key', projectIds: [project.id]
          }
        }
        expect(response).to have_http_status(:created)
        expect(PublishTarget.find_by!(string_key: 'publish_targets_spec_b').projects).to eq([project])
      end

      it 'returns validation errors for an invalid publish target' do
        post api_v2_publish_targets_path, as: :json, params: { publishTarget: { stringKey: 'Invalid Key' } }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json['errors'].keys).to include('stringKey', 'displayLabel', 'publishUrl', 'apiKey')
      end
    end

    describe 'PATCH /api/v2/publish_targets/:string_key' do
      it 'updates a publish target without changing its string key' do
        patch api_v2_publish_target_path(publish_target.string_key), as: :json, params: {
          publishTarget: { displayLabel: 'Renamed Publish Target', stringKey: 'publish_targets_spec_renamed' }
        }
        expect(response).to have_http_status(:ok)
        expect(publish_target.reload.display_label).to eq('Renamed Publish Target')
        expect(publish_target.string_key).to eq('publish_targets_spec_a')
      end
    end

    describe 'DELETE /api/v2/publish_targets/:string_key' do
      let(:digital_object_record) { DigitalObjectRecord.create!(pid: 'publish_targets_spec:1') }

      it 'deletes a publish target that is not in use' do
        delete api_v2_publish_target_path(publish_target.string_key)
        expect(response).to have_http_status(:no_content)
        expect(PublishTarget.exists?(publish_target.id)).to eq(false)
      end

      it 'does not delete a publish target that is selected for a digital object' do
        digital_object_record.publish_targets << publish_target
        delete api_v2_publish_target_path(publish_target.string_key)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(PublishTarget.exists?(publish_target.id)).to eq(true)
      end

      it 'does not delete a publish target that a digital object may still be published to' do
        digital_object_record.publications.create!(publish_target: publish_target, status: :publish_pending)
        delete api_v2_publish_target_path(publish_target.string_key)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(PublishTarget.exists?(publish_target.id)).to eq(true)
      end

      it 'deletes a publish target that all digital objects have been unpublished from' do
        digital_object_record.publications.create!(publish_target: publish_target, status: :unpublished)
        delete api_v2_publish_target_path(publish_target.string_key)
        expect(response).to have_http_status(:no_content)
        expect(PublishTarget.exists?(publish_target.id)).to eq(false)
      end
    end
  end
end
