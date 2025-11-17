require "rails_helper"

RSpec.describe Projects::DynamicFieldsController, :type => :controller do
  before { controller_test_sign_in_admin_user() }

  # This should return the set of valid attributes for update.
  let(:update_attributes) {
    skip("Add a hash of attributes valid for your model")
  }

  let(:invalid_attributes) {
    skip("Add a hash of attributes invalid for your model")
  }

  let(:project_id) { "spec_project" }
  let(:digital_object_type_id) { "spec_member" }

  let(:project) do
    _p = double(Project)
    allow(_p).to receive(:id).and_return(project_id)
    _p
  end

  let(:digital_object_type) { double(DigitalObjectType) }

  let(:valid_session) { {} }

  describe '#edit' do
    before do
      allow(Project).to receive(:find).with(project_id).and_return(project)
      allow(DigitalObjectType).to receive(:find).with(digital_object_type_id).and_return(digital_object_type)
      get :edit, params: {id: project_id, digital_object_type_id: digital_object_type_id }, session: valid_session
    end

    it 'returns the expected status' do
      expect(response.status).to eq(200)
    end

    it 'assigns the expected project instance variable' do
      expect(assigns(:project)).to eql(project)
    end

    it 'assigns the expected digital_object_type instance variable' do
      expect(assigns(:digital_object_type)).to eql(digital_object_type)
    end
  end

  describe '#update' do
    before do
      allow(Project).to receive(:find).with(project_id).and_return(project)
      allow(project).to receive(:update).with({}).and_return(true)
      allow(DigitalObjectType).to receive(:find).with(digital_object_type_id).and_return(digital_object_type)
      patch :update, params: {id: project_id, digital_object_type_id: digital_object_type_id, project: {a: :b} }, session: valid_session
    end
    it { expect(response).to redirect_to("/projects/#{project_id}/dynamic_fields/edit?digital_object_type_id=#{digital_object_type_id}")}
  end

  describe '#show' do
    it {}
  end
end
