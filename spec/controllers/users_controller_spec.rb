require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  describe 'do_cas_login' do
    let(:action_url) { "#{request_host}/users/do_cas_login" }
    let(:cas_login_uri) { 'https://cas.columbia.edu/cas/login' }
    let(:expected_redirect_url) { "#{cas_login_uri}?service=#{URI::DEFAULT_PARSER.escape(action_url)}" } 
    let(:request_host) { request.protocol + request.host_with_port }
    let(:user_uni) { 'user_uni' }
    let(:well_known_ticket_value) { 'well_known_ticket_value' }

    context 'there is no :ticket param' do
      it 'redirects to the CAS login' do
        expect(controller).to receive(:redirect_to).with(expected_redirect_url)
        controller.do_cas_login
      end
    end

    context 'there is a :ticket param' do
      before do
        controller.params[:ticket] = well_known_ticket_value
        allow(controller).to receive(:get_uni_from_cas).with(a_string_starting_with('https://cas.columbia.edu')).and_return(user_uni)
      end

      it 'calls identify_uni_user with the parsed uni from cas' do
        expect(controller).to receive(:identify_uni_user).with(user_uni, a_string_starting_with('https://cas.columbia.edu'))
        controller.do_cas_login
      end
    end
  end

  describe 'identify_uni_user' do
    let(:cas_logout_uri) { 'cas_logout_uri' }
    let(:expected_cas_logout) { cas_logout_uri + '?service=' + URI::DEFAULT_PARSER.escape(root_url) }
    let(:root_path) { controller.root_path }
    let(:root_url) { controller.root_url }
    let(:user_uni) { 'user_uni' }

    it "redirects to root_path and returns a status of 302" do
      expect(controller).to receive(:redirect_to).with(expected_cas_logout)
      controller.identify_uni_user(user_uni, cas_logout_uri)
    end

    context 'User is present' do
      before do
        FactoryBot.create(:non_admin_user, email: (user_uni + '@columbia.edu'))
      end

      after do
        User.find_by(email: (user_uni + '@columbia.edu')).destroy
      end

      it "redirects to root_path and returns a status of 302" do
        expect(controller).to receive(:redirect_to).with(root_path, status: 302)
        controller.identify_uni_user(user_uni, cas_logout_uri)
        expect(controller.flash[:notice]).to eql 'You are now logged in.'
      end
    end
  end
end