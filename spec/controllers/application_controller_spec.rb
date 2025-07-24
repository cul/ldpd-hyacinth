require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  before(:context) do
    @application_controller = ApplicationController.new
  end

  before(:example) do
    @current_user_mock = double(User)
    allow(@current_user_mock).to receive(:admin?) {false}
    allow(@application_controller).to receive(:current_user) { @current_user_mock }
    allow(@application_controller).to receive(:render_forbidden!) { :render_forbidden_mock_called }
  end

  context "#check_project_permissions_and:" do
    it("User: Read permission, Required: Write permission, so render_forbidden! called.") do
      allow(@current_user_mock).to receive(:permitted_in_project?).with("Test","Write") {false}
      expect(@application_controller.require_project_permission!("Test","Write")).to eq(:render_forbidden_mock_called)
    end

    it("User: Read permission, Required: Read permission, so just return") do
      allow(@current_user_mock).to receive(:permitted_in_project?).with("Test","Read") {true}
      expect(@application_controller.require_project_permission!("Test","Read")).to eq(nil)
    end

    it("User: Read permission, Required: Read AND Write permission, so render_forbidden! called") do
      allow(@current_user_mock).to receive(:permitted_in_project?).with("Test","Read") {true}
      allow(@current_user_mock).to receive(:permitted_in_project?).with("Test","Write") {false}
      expect(@application_controller.require_project_permission!("Test",["Read","Write"],:and)).to eq(:render_forbidden_mock_called)
    end

    it("User: Read permission, Required: Write AND Read permission, so render_forbidden! called") do
      allow(@current_user_mock).to receive(:permitted_in_project?).with("Test","Read") {true}
      allow(@current_user_mock).to receive(:permitted_in_project?).with("Test","Write") {false}
      expect(@application_controller.require_project_permission!("Test",["Write","Read"],:and)).to eq(:render_forbidden_mock_called)
    end

    it("User: Read and Write permission, Required: Write AND Read permission, so just return") do
      allow(@current_user_mock).to receive(:permitted_in_project?).with("Test","Read") {true}
      allow(@current_user_mock).to receive(:permitted_in_project?).with("Test","Write") {true}
      expect(@application_controller.require_project_permission!("Test",["Write","Read"],:and)).to eq(nil)
    end

    it("User: Read permission, Required: Read AND (Default) Write permission, so render_forbidden! called") do
      allow(@current_user_mock).to receive(:permitted_in_project?).with("Test","Read") {true}
      allow(@current_user_mock).to receive(:permitted_in_project?).with("Test","Write") {false}
      expect(@application_controller.require_project_permission!("Test",["Read","Write"])).to eq(:render_forbidden_mock_called)
    end

    it("User: Read permission, Required: Write AND (Default) Read permission, so render_forbidden! called") do
      allow(@current_user_mock).to receive(:permitted_in_project?).with("Test","Read") {true}
      allow(@current_user_mock).to receive(:permitted_in_project?).with("Test","Write") {false}
      expect(@application_controller.require_project_permission!("Test",["Write","Read"])).to eq(:render_forbidden_mock_called)
    end

    it("User: Read and Write permission, Required: Write AND (Default) Read permission, so just return") do
      allow(@current_user_mock).to receive(:permitted_in_project?).with("Test","Read") {true}
      allow(@current_user_mock).to receive(:permitted_in_project?).with("Test","Write") {true}
      expect(@application_controller.require_project_permission!("Test",["Write","Read"])).to eq(nil)
    end

    it("User: Read permission, Required: Read OR Write permission, so just return") do
      allow(@current_user_mock).to receive(:permitted_in_project?).with("Test","Read") {true}
      allow(@current_user_mock).to receive(:permitted_in_project?).with("Test","Write") {false}
      expect(@application_controller.require_project_permission!("Test",["Read","Write"],:or)).to eq(nil)
    end

    it("User: Read permission, Required: Write OR Read permission, so just return") do
      allow(@current_user_mock).to receive(:permitted_in_project?).with("Test","Read") {true}
      allow(@current_user_mock).to receive(:permitted_in_project?).with("Test","Write") {false}
      expect(@application_controller.require_project_permission!("Test",["Write","Read"],:or)).to eq(nil)
    end

    it("User: Read permission, Required: Write OR Update permission, so render_forbidden!") do
      allow(@current_user_mock).to receive(:permitted_in_project?).with("Test","Read") {true}
      allow(@current_user_mock).to receive(:permitted_in_project?).with("Test","Write") {false}
      allow(@current_user_mock).to receive(:permitted_in_project?).with("Test","Update") {false}
      expect(@application_controller.require_project_permission!("Test",["Write","Update"],:or)).to eq(:render_forbidden_mock_called)
    end

    it("User: admin, so just return") do
      allow(@current_user_mock).to receive(:admin?) {true}
      allow(@current_user_mock).to receive(:permitted_in_project?).with("Test","Read") {false}
      allow(@current_user_mock).to receive(:permitted_in_project?).with("Test","Write") {false}
      expect(@application_controller.require_project_permission!("Test",["Read","Write"],:and)).to eq(nil)
    end
  end

  describe 'after_sign_out_path_for' do
    let(:cookies) { {} }
    let(:well_known_cookie_value) { 'well_known_cookie_value' }
    let(:_resource) { nil } #u nused param

    subject(:returned_path) { controller.after_sign_out_path_for(_resource) }

    before do
      allow(controller).to receive(:cookies).and_return(cookies)
    end

    it 'returns the root_url' do
      expect(returned_path).to eql(controller.root_url)
    end

    context 'signed_in_using_uni' do
      let(:cookies) { { signed_in_using_uni: well_known_cookie_value } }
      it 'deletes the cookie and returns a cas logout URL' do
        expect(returned_path).to start_with('https://cas.columbia.edu/cas/logout?service=')
        expect(cookies).not_to include(:signed_in_using_uni)
      end
    end
  end
end
