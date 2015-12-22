require "rails_helper"

describe Projects::DynamicFieldsController, type: :routing do
  routes { Hyacinth::Application.routes }
  let(:path_params) { { controller: 'projects/dynamic_fields', id: '1', digital_object_type_id: 2 } }
  let(:base_params) { path_params.merge(action: action) }
  let(:request_params) { base_params.merge( digital_object_type_id: '2') }

  describe '#edit' do
    let(:action) { 'edit' }
    it "routes" do
      expect(:get => "/projects/1/dynamic_fields/edit?digital_object_type_id=2").to route_to(request_params)
    end
  end

  describe '#update' do
    let(:action) { 'update' }
    it 'routes' do
      expect(:put => "/projects/1/dynamic_fields?digital_object_type_id=2").to route_to(request_params)
    end
    it 'routes' do
      expect(:patch => "/projects/1/dynamic_fields?digital_object_type_id=2").to route_to(request_params)
    end
  end

  describe '#show' do
    let(:action) { :show }
    it 'is a disabled route' do
      expect(:get => "/projects/1/dynamic_fields").not_to be_routable
    end
  end

  describe '#index' do
    let(:action) { :index }
    it 'is a disabled route' do
      expect(:get => "/projects/1/dynamic_fields").not_to be_routable
    end
  end

  describe 'url helpers' do
    it "builds a show/update url" do
      expect(enabled_dynamic_fields_path(path_params)).to eql("/projects/1/dynamic_fields?digital_object_type_id=2")
    end
    it "builds an edit url" do
      expect(edit_enabled_dynamic_fields_path(path_params.merge(action: :edit))).to eql("/projects/1/dynamic_fields/edit?digital_object_type_id=2")
    end
  end
end
