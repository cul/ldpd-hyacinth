class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery
  # For JSON api, recommended by: http://api.rubyonrails.org/classes/ActionController/RequestForgeryProtection.html
  skip_before_action :verify_authenticity_token, if: :json_request?

  before_action :set_start_time, :handle_token_auth!, :initialize_admin_contextual_menu, :require_authenticated_user!

  add_flash_types :persistent_notice # A notice that must be closed by the user and won't auto-close

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
      'https://cas.columbia.edu/cas/logout?service=' + URI::DEFAULT_PARSER.escape(root_url)
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
  end

  def render_unauthorized!
    respond_to do |format|
      format.html { render 'pages/unauthorized', status: :unauthorized }
      format.all { render json: { error: 'Unauthorized' }, status: :unauthorized }
    end
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

    # Our token auth uses Basic authentication and expects a user to pass a token in the Basic auth
    # password field.  When users authenticate through this process, we do not create a Devise session
    # (meaning we do not set a cookie).
    def handle_token_auth!
      return if user_signed_in? # No need to check for auth if the user is already signed in

      # Our API auth uses the basic auth protocol, but expects an API key as a password.
      basic_auth_match = request.authorization&.match(/^(Basic )(.+)/)
      return unless basic_auth_match
      basic_auth_credentials = Base64.strict_decode64(basic_auth_match[2]).split(':')
      return unless basic_auth_credentials.length == 2

      # TODO: Change this to User.find_by(uid: basic_auth_credentials[0]) once uid field is added later on.
      possible_user = User.find_by(email: basic_auth_credentials[0])

      # If this user has never set up an API key, do not allow them to log in.
      if possible_user.api_key_digest.nil?
        # TODO: Change user.email below to self.uid once we add that field
        Rails.logger.error("User with email #{self.email} attempted to log in, but login was rejected because this user has not set up an API key.")
        return
      end

      if possible_user && possible_user.authenticate_api_key(basic_auth_credentials[1])
        request.session_options[:skip] = true # Skip Devise session.  Do not set a session cookie.
        sign_in possible_user
      end
    end
end
