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
      allow(@current_user_mock).to receive(:has_project_permission?).with("Test","Write") {false}
      expect(@application_controller.require_project_permission!("Test","Write")).to eq(:render_forbidden_mock_called)
    end

    it("User: Read permission, Required: Read permission, so just return") do
      allow(@current_user_mock).to receive(:has_project_permission?).with("Test","Read") {true}
      expect(@application_controller.require_project_permission!("Test","Read")).to eq(nil)
    end

    it("User: Read permission, Required: Read AND Write permission, so render_forbidden! called") do
      allow(@current_user_mock).to receive(:has_project_permission?).with("Test","Read") {true}
      allow(@current_user_mock).to receive(:has_project_permission?).with("Test","Write") {false}
      expect(@application_controller.require_project_permission!("Test",["Read","Write"],:and)).to eq(:render_forbidden_mock_called)
    end

    it("User: Read permission, Required: Write AND Read permission, so render_forbidden! called") do
      allow(@current_user_mock).to receive(:has_project_permission?).with("Test","Read") {true}
      allow(@current_user_mock).to receive(:has_project_permission?).with("Test","Write") {false}
      expect(@application_controller.require_project_permission!("Test",["Write","Read"],:and)).to eq(:render_forbidden_mock_called)
    end

    it("User: Read and Write permission, Required: Write AND Read permission, so just return") do
      allow(@current_user_mock).to receive(:has_project_permission?).with("Test","Read") {true}
      allow(@current_user_mock).to receive(:has_project_permission?).with("Test","Write") {true}
      expect(@application_controller.require_project_permission!("Test",["Write","Read"],:and)).to eq(nil)
    end

    it("User: Read permission, Required: Read AND (Default) Write permission, so render_forbidden! called") do
      allow(@current_user_mock).to receive(:has_project_permission?).with("Test","Read") {true}
      allow(@current_user_mock).to receive(:has_project_permission?).with("Test","Write") {false}
      expect(@application_controller.require_project_permission!("Test",["Read","Write"])).to eq(:render_forbidden_mock_called)
    end

    it("User: Read permission, Required: Write AND (Default) Read permission, so render_forbidden! called") do
      allow(@current_user_mock).to receive(:has_project_permission?).with("Test","Read") {true}
      allow(@current_user_mock).to receive(:has_project_permission?).with("Test","Write") {false}
      expect(@application_controller.require_project_permission!("Test",["Write","Read"])).to eq(:render_forbidden_mock_called)
    end

    it("User: Read and Write permission, Required: Write AND (Default) Read permission, so just return") do
      allow(@current_user_mock).to receive(:has_project_permission?).with("Test","Read") {true}
      allow(@current_user_mock).to receive(:has_project_permission?).with("Test","Write") {true}
      expect(@application_controller.require_project_permission!("Test",["Write","Read"])).to eq(nil)
    end

    it("User: Read permission, Required: Read OR Write permission, so just return") do
      allow(@current_user_mock).to receive(:has_project_permission?).with("Test","Read") {true}
      allow(@current_user_mock).to receive(:has_project_permission?).with("Test","Write") {false}
      expect(@application_controller.require_project_permission!("Test",["Read","Write"],:or)).to eq(nil)
    end

    it("User: Read permission, Required: Write OR Read permission, so just return") do
      allow(@current_user_mock).to receive(:has_project_permission?).with("Test","Read") {true}
      allow(@current_user_mock).to receive(:has_project_permission?).with("Test","Write") {false}
      expect(@application_controller.require_project_permission!("Test",["Write","Read"],:or)).to eq(nil)
    end

    it("User: Read permission, Required: Write OR Update permission, so render_forbidden!") do
      allow(@current_user_mock).to receive(:has_project_permission?).with("Test","Read") {true}
      allow(@current_user_mock).to receive(:has_project_permission?).with("Test","Write") {false}
      allow(@current_user_mock).to receive(:has_project_permission?).with("Test","Update") {false}
      expect(@application_controller.require_project_permission!("Test",["Write","Update"],:or)).to eq(:render_forbidden_mock_called)
    end

    it("User: admin, so just return") do
      allow(@current_user_mock).to receive(:admin?) {true}
      allow(@current_user_mock).to receive(:has_project_permission?).with("Test","Read") {false}
      allow(@current_user_mock).to receive(:has_project_permission?).with("Test","Write") {false}
      expect(@application_controller.require_project_permission!("Test",["Read","Write"],:and)).to eq(nil)
    end
  end
end
