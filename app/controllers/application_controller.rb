class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery
  # For JSON api, recommended by: http://api.rubyonrails.org/classes/ActionController/RequestForgeryProtection.html
  skip_before_action :verify_authenticity_token, if: :json_request?

  before_action :set_start_time, :initialize_admin_contextual_menu, :require_authenticated_user!

  def initialize_admin_contextual_menu
    @contextual_nav_options = Hash.new
    @contextual_nav_options['nav_title'] = Hash.new
    @contextual_nav_options['nav_items'] = []
  end

  def set_start_time
    @page_load_start_time = Time.now
  end

  # Doing a basic override of the render method for performance monitoring reasons (setting @time_before_render variable)
  def render(*args)
    @time_before_render = Time.now
    super
  end

  def require_authenticated_user!
    if ! user_signed_in?

      if (params[:controller] == 'pages' && params[:action] == 'home') ||
        (params[:controller] == 'devise/sessions') ||
        (params[:controller] == 'users' && params[:action] == 'do_wind_login') ||
        (params[:controller] == 'users' && params[:action] == 'do_cas_login') ||
        (params[:controller] == 'pages' && params[:action] == 'login_check') ||
        (params[:controller] == 'pages' && params[:action] == 'get_csrf_token')
       # Allow access
      else
        session["login_redirect_to"] = request.fullpath if ! json_request? && session["login_redirect_to"].blank?
        render_unauthorized!
      end
    end
  end

  def after_sign_in_path_for(resource)
    session["login_redirect_to"] || root_path
  end
  
  def after_sign_out_path_for(resource)
    if cookies[:signed_in_using_uni]
      # Log out of CAS sessions
      cookies.delete(:signed_in_using_uni)
      return 'https://cas.columbia.edu/cas/logout?service=' + URI::escape(root_url)
    else
      return root_url
    end
  end

  # Permission/Authorization methods

  def render_forbidden!
    respond_to do |format|
      format.html {
        render 'pages/forbidden', :status => :forbidden
      }
      format.all {
        render json: {error: 'Forbidden'}, :status => :forbidden
      }
    end
  end

  def render_unauthorized!
    respond_to do |format|
      format.html {
        render 'pages/unauthorized', :status => :unauthorized
      }
      format.all {
        render json: {error: 'Unauthorized'}, :status => :unauthorized
      }
    end
  end

  def require_hyacinth_admin!
    unless current_user.is_admin?
      render_forbidden!
    end
  end

  def require_controlled_vocabulary_permission!(controlled_vocabulary)
    unless current_user.can_manage_controlled_vocabulary_terms?(controlled_vocabulary)
      render_forbidden!
    end
  end

  def require_project_permission!(project, permission_type)

    # Always allow access if this user is an admin
    return if current_user.is_admin?

    return if current_user.has_project_permission?(project, permission_type)

    render_forbidden!
  end

  protected

  # For JSON api, recommended by: http://api.rubyonrails.org/classes/ActionController/RequestForgeryProtection.html
  def json_request?
    request.format.json?
  end

end
