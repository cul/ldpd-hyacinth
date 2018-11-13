class ApplicationController < ActionController::Base
  before_action :require_authenticated_user!

  layout :layout_by_resource

  private

  def require_authenticated_user!
    return if user_signed_in? || params[:controller] == 'devise/sessions'
    exempt_resources = {
      'users' => ['do_cas_login']
    }

    # Allow access to exempt requests
    return if exempt_resources.fetch(params[:controller], []).include?(params[:action])

    respond_to do |format|
      format.html { render 'pages/unauthorized', status: :unauthorized, layout: 'login' }
      format.all { render json: { error: 'Unauthorized' }, status: :unauthorized }
    end
  end

  # choose 'login' layout whenever we're using a devise controller
  def layout_by_resource
    if devise_controller?
      "login"
    else
      "application"
    end
  end

end
