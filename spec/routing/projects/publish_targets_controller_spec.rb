require "rails_helper"

describe Projects::PublishTargetsController, type: :routing do
  routes { Rails.application.routes }
  let(:path_params) { { controller: 'projects/publish_targets', id: '1' } }
  let(:params) { path_params.merge(action: action) }

  describe '#edit' do
    let(:action) { 'edit' }
    it "routes" do
      expect(:get => "/projects/1/publish_targets/edit").to route_to(params)
    end
  end

  describe '#update' do
    let(:action) { 'update' }
    it 'routes' do
      expect(:put => "/projects/1/publish_targets").to route_to(params)
    end
    it 'routes' do
      expect(:patch => "/projects/1/publish_targets").to route_to(params)
    end
  end

  describe '#show' do
    let(:action) { :show }
    it 'is a disabled route' do
      expect(:get => "/projects/1/publish_targets").not_to route_to(params)
    end
  end

  describe 'url helpers' do
    it "builds a show/update url" do
      action = 'show'
      expect(project_publish_targets_path(path_params)).to eql("/projects/1/publish_targets")
    end
    it "builds an edit url" do
      action = 'edit'
      expect(edit_project_publish_targets_path(path_params)).to eql("/projects/1/publish_targets/edit")
    end
  end
end
