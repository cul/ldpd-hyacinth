# frozen_string_literal: true

require 'rails_helper'

describe 'Logging in', type: :request do
  context 'when initiating CAS authentication' do
    before { get '/users/do_cas_login' }
    it 'redirects to columbia login page' do
      expect(response).to redirect_to 'https://cas.columbia.edu/cas/login?service=http%3A%2F%2Fwww.example.com%2Fusers%2Fdo_cas_login'
    end
  end

  context 'when CAS request contains a ticket param' do
    let(:ticket) { SecureRandom.alphanumeric }
    let(:ticket_validation_response) do
      <<~TICKET
        <cas:serviceResponse xmlns:cas='http://www.yale.edu/tp/cas'>
          <cas:authenticationSuccess>
            <cas:user>#{uni}</cas:user>
          </cas:authenticationSuccess>
        </cas:serviceResponse>
      TICKET
    end

    # Stub response that checks ticket is valid.
    before do
      stub_request(
        :get,
        "https://cas.columbia.edu/cas/serviceValidate?service=http%3A%2F%2Fwww.example.com%2Fusers%2Fdo_cas_login&ticket=#{ticket}"
      ).to_return(body: ticket_validation_response)
    end

    context 'when user has an account' do
      let(:uni) { 'abc123' }

      before do
        FactoryBot.create(:user, email: "#{uni}@columbia.edu")
        get '/users/do_cas_login', params: { ticket: ticket }
      end

      it 'redirects to application root url' do
        expect(response).to redirect_to root_url
      end
    end

    context 'when user does not have an account' do
      let(:uni) { 'abc123' }
      let(:flash_message) do
        <<~MESSAGE
          The UNI abc123 is not authorized to log into Hyacinth (no account exists with email abc123@columbia.edu).
          If you believe that you should have access, please contact an application administrator.
        MESSAGE
      end
      let(:normalized_flash_message) { flash_message.strip.gsub(/\s+/,' ') }

      before { get '/users/do_cas_login', params: { ticket: ticket } }

      it 'error is displayed via flash notice' do
        expect(flash[:notice].strip.gsub(/\s+/,' ')).to be_eql normalized_flash_message
      end

      it 'redirected to logout' do
        expect(response).to redirect_to 'https://cas.columbia.edu/cas/logout?service=http%3A%2F%2Fwww.example.com%2F'
      end
    end
  end

  context 'when logging in with email and password' do
    context 'when account exists' do
      before do
        FactoryBot.create(:user)
        post '/users/sign_in', params: { user: { email: 'jane-doe@example.com', password: 'terriblepassword' } }
      end

      it 'redirects to application root url' do
        expect(response).to redirect_to root_url
      end
    end

    context 'when account does not exist' do
      before do
        post '/users/sign_in', params: { user: { email: "example@cool.com", password: "something" } }
      end

      it 'error is displayed via flash notice' do
        expect(flash[:alert]).to be_eql 'Invalid Email or password.'
      end
    end

    context 'when password is invalid' do
      before do
        FactoryBot.create(:user)
        post '/users/sign_in', params: { user: { email: 'jane-doe@example.com', password: 'nottherightpassword' } }
      end

      it 'error is displayed via flash notice' do
        expect(flash[:alert]).to be_eql 'Invalid Email or password.'
      end
    end
  end
end
