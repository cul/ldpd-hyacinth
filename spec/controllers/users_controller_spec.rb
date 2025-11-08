require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  # describe 'identify_uni_user' do
  #   let(:cas_logout_uri) { 'cas_logout_uri' }
  #   let(:expected_cas_logout) { cas_logout_uri + '?service=' + URI::DEFAULT_PARSER.escape(root_url) }
  #   let(:root_path) { controller.root_path }
  #   let(:root_url) { controller.root_url }
  #   let(:user_uni) { 'user_uni' }

  #   it "redirects to root_path and returns a status of 302" do
  #     expect(controller).to receive(:redirect_to).with(expected_cas_logout)
  #     controller.identify_uni_user(user_uni, cas_logout_uri)
  #   end

  #   context 'User is present' do
  #     let(:is_active) { true }
  #     let(:user_opts) do
  #       { email: (user_uni + '@columbia.edu'), is_active: is_active }
  #     end

  #     before do
  #       FactoryBot.create(:non_admin_user, user_opts)
  #     end

  #     after do
  #       User.find_by(email: user_opts[:email]).destroy
  #     end

  #     context 'user is active' do
  #       it "redirects to root_path and returns a status of 302" do
  #         expect(controller).to receive(:redirect_to).with(root_path, status: 302)
  #         controller.identify_uni_user(user_uni, cas_logout_uri)
  #         expect(controller.flash[:notice]).to eql 'You are now logged in.'
  #       end
  #     end

  #     context 'user is inactive' do
  #       let(:is_active) { false }

  #       it "redirects to root_path and returns a status of 302" do
  #         expect(controller).to receive(:redirect_to).with(expected_cas_logout)
  #         controller.identify_uni_user(user_uni, cas_logout_uri)
  #       end
  #     end
  #   end
  # end
end
