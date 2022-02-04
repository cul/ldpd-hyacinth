# frozen_string_literal: true

module Hyacinth
  module Users
    module CasAuthenticationBehavior
      extend ActiveSupport::Concern

      # GET /users/do_cas_login
      def do_cas_login
        cas_server_uri = 'https://cas.columbia.edu'
        cas_login_uri = cas_server_uri + '/cas/login'
        cas_validate_uri = cas_server_uri + '/cas/serviceValidate'
        cas_logout_uri = cas_server_uri + '/cas/logout'

        redirect_to root_path if user_signed_in?

        if !params[:ticket]
          # Login: Part 1

          # If ticket is NOT set, this means that the user hasn't gotten to the uni/password login page yet.  Let's send them there.
          # After they log in, they'll be redirected to this page and they'll continue with the authentication.

          redirect_to(cas_login_uri + '?service=' + URI.encode_www_form_component(request.protocol + request.host_with_port + '/users/do_cas_login'))
        else
          # Login: Part 2
          # If ticket is set, we'll use that ticket for login part 2.

          # We'll validate the ticket against the cas server
          full_validate_uri = cas_validate_uri + '?service=' + URI.encode_www_form_component(request.protocol + request.host_with_port + '/users/do_cas_login') + '&ticket=' + params['ticket']

          uri = URI.parse(full_validate_uri)
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE if Rails.env.development?

          cas_request = Net::HTTP::Get.new(uri.request_uri)
          response_body = http.request(cas_request).body

          user_uni = nil

          # We are always expecting an XML response
          xml_response = Nokogiri::XML(response_body)
          xpath_selection = xml_response.xpath('/cas:serviceResponse/cas:authenticationSuccess/cas:user', 'cas' => 'http://www.yale.edu/tp/cas')
          user_uni = xpath_selection.first.text if xpath_selection.present?

          identify_uni_user(user_uni, cas_logout_uri)
        end
      end

      private

        def identify_uni_user(user_uni, cas_logout_uri)
          if user_uni.present?
            user_email = "#{user_uni}@columbia.edu"
            possible_user = User.find_by(email: user_email)

            if possible_user.present? && possible_user.is_active
              bypass_sign_in possible_user
              cookies[:signed_in_using_uni] = true # Use this cookie to know when to do a CAS logout upon Devise logout
              flash[:notice] = I18n.t('devise.sessions.signed_in')

              redirect_to root_path, status: :found
            else
              flash[:alert] = possible_user.present? ? I18n.t('devise.failure.inactive') : I18n.t('devise.failure.unauthorized', uni: user_uni, email: user_email)
              # Log out user
              redirect_to(cas_logout_uri + '?service=' + URI.encode_www_form_component(root_url))
            end
          else
            render inline: I18n.t('devise.failure.provider', provider: 'CAS')
          end
        end
    end
  end
end
