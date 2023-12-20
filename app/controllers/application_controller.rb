class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery prepend: true
  # For JSON api, recommended by: http://api.rubyonrails.org/classes/ActionController/RequestForgeryProtection.html
  skip_before_action :verify_authenticity_token, if: :json_request?

  before_action :set_start_time, :initialize_admin_contextual_menu, :require_authenticated_user!

  def initialize_admin_contextual_menu
    @contextual_nav_options = {}
    @contextual_nav_options['nav_title'] = {}
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
    return if user_signed_in? || params[:controller] == 'devise/sessions'
    pre_authn_requests = {
      'pages' => ['home', 'login_check', 'csrf_token'],
      'users' => ['do_wind_login', 'do_cas_login']
    }

    # Allow access to exempt requests
    return if pre_authn_requests.fetch(params[:controller], []).include?(params[:action])

    session["login_redirect_to"] = request.fullpath unless json_request? || session["login_redirect_to"].present?
    render_unauthorized!
  end

  def after_sign_in_path_for(_resource)
    session["login_redirect_to"] || root_path
  end

  def after_sign_out_path_for(_resource)
    if cookies[:signed_in_using_uni]
      # Log out of CAS sessions
      cookies.delete(:signed_in_using_uni)
      'https://cas.columbia.edu/cas/logout?service=' + URI.escape(root_url)
    else
      root_url
    end
  end

  # Permission/Authorization methods

  def render_forbidden!
    respond_to do |format|
      format.html { render 'pages/forbidden', status: :forbidden }
      format.all { render json: { error: 'Forbidden' }, status: :forbidden }
    end
    throw(:abort)
  end

  def render_unauthorized!
    respond_to do |format|
      format.html { render 'pages/unauthorized', status: :unauthorized }
      format.all { render json: { error: 'Unauthorized' }, status: :unauthorized }
    end
    throw(:abort)
  end

  def require_hyacinth_admin!
    render_forbidden! unless current_user.admin?
  end

  def require_controlled_vocabulary_permission!(controlled_vocabulary)
    render_forbidden! unless current_user.can_manage_controlled_vocabulary_terms?(controlled_vocabulary)
  end

  def assignee_for_type?(digital_object, assignment_task_type)
    # since assignment_task_type is an enum, we want to accept and handle either the string or numeric versions
    assignment_task_type = Assignment.tasks[assignment_task_type] if assignment_task_type.is_a?(String)
    Assignment.exists?(assignee: current_user, digital_object_pid: digital_object.pid, task: assignment_task_type)
  end

  def require_project_permission!(project, permission_types, logic_operation = :and)
    # Always allow access if this user is an admin
    return if current_user.admin?

    permission_types = Array(permission_types)

    case logic_operation
    when :and
      return if check_project_permissions_and(project, permission_types)
    when :or
      return if check_project_permissions_or(project, permission_types)
    end
    render_forbidden!
  end

  protected

    # For JSON api, recommended by: http://api.rubyonrails.org/classes/ActionController/RequestForgeryProtection.html
    def json_request?
      request.format.json?
    end

  private

    def check_project_permissions_and(project, permission_types)
      permission_types.each do |permission|
        return false unless current_user.permitted_in_project?(project, permission)
      end
      true
    end

    def check_project_permissions_or(project, permission_types)
      permission_types.each do |permission|
        return true if current_user.permitted_in_project?(project, permission)
      end
      false
    end
end
