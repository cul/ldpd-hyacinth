class Api::V2::UsersController < Api::V2::BaseController
  API_TOKEN_LENGTH = 32

  before_action :set_user_by_uid, only: [:show, :update, :generate_new_api_key, :project_permissions, :update_project_permissions]

  # GET /api/v2/users
  def index
    authorize! :index, User
    @users = User.all.order(uid: :asc)
    render json: { users: @users.map { |user| user_json(user) } }
  end

  # POST /api/v2/users
  def create
    authorize! :create, User
    @user = User.new(user_params)

    if @user.save
      render json: { user: user_json(@user) }, status: :created
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # GET /api/v2/users/:uid
  # Admin or self
  def show
    authorize! :show, @user
    render json: { user: user_json(@user) }
  end

  # GET /api/v2/users/_self
  def _self
    respond_to do |format|
      format.json do
        if current_user
          render json: { user: user_json(current_user) }
        else
          render json: { user: nil }, status: :unauthorized
        end
      end
    end
  end

  # PATCH /api/v2/users/:uid
  # Admin or self
  def update
    authorize! :update, @user
    
    # Prevent admins from changing their own is_admin status
    if current_user.admin? && @user.id == current_user.id && user_params.key?(:is_admin)
      authorize! :update_is_admin, @user
    end
    
    if @user.update(user_params)
      render json: { user: user_json(@user) }
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # POST /api/v2/users/:uid/generate_new_api_key
  # Admin or self
  def generate_new_api_key
    authorize! :generate_api_key, @user

    new_api_key = Devise.friendly_token(API_TOKEN_LENGTH)

    if @user.update(api_key: new_api_key)
      render json: { 
        apiKey: new_api_key,
      }, status: :ok
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # GET /api/v2/users/:uid/project_permissions
  # Admin or self (read-only for self)
  def project_permissions
    authorize! :read_project_permissions, @user

    project_permissions = user_project_permissions_json(@user)

    render json: { projectPermissions: project_permissions }, status: :ok
  end

  # PUT /api/v2/users/:uid/project_permissions
  # Admin only
  def update_project_permissions
    authorize! :update_project_permissions, @user

    # Check that the key exists (even if empty)
    unless params.key?(:project_permissions)
      render json: { errors: ["Missing required parameter: project_permissions"] }, status: :bad_request
      return
    end

    updated_permissions = []

    @user.transaction do
      @user.project_permissions.destroy_all
      permissions_data = params[:project_permissions] || []

      # If empty, we're done - user has no project permissions
      if permissions_data.empty?
        next
      end

      new_permissions = permissions_data.map do |permission_params|
        {
          user_id: @user.id,
          project_id: permission_params[:project_id],
          can_read: permission_params[:can_read] || false,
          can_create: permission_params[:can_create] || false,
          can_update: permission_params[:can_update] || false,
          can_delete: permission_params[:can_delete] || false,
          can_publish: permission_params[:can_publish] || false,
          is_project_admin: permission_params[:is_project_admin] || false,
        }
      end

      # Validate that all projects exist before inserting
      project_ids = new_permissions.map { |p| p[:project_id] }
      existing_project_ids = Project.where(id: project_ids).pluck(:id)
      missing_project_ids = project_ids - existing_project_ids
      
      if missing_project_ids.any?
        render json: { errors: ["Projects not found: #{missing_project_ids.join(', ')}"] }, status: :not_found
        raise ActiveRecord::Rollback
      end

      ProjectPermission.insert_all(new_permissions)
      updated_permissions = user_project_permissions_json(@user)
    end
    render json: { projectPermissions: updated_permissions }, status: :ok
  rescue ActiveRecord::RecordNotFound => e
    render json: { errors: ["Project not found: #{e.message}"] }, status: :not_found
  end

  private

  def set_user_by_uid
    @user = User.find_by!(uid: params[:uid])
  end

  def user_params
    # Admins can set all fields, regular users can only update their own non-privileged fields
    if current_user.admin?
      params.require(:user).permit(
        :uid, :email, :first_name, :last_name,
        :is_admin, :can_manage_all_controlled_vocabularies, :is_active, :account_type, :api_key_digest
      )
    else
      params.require(:user).permit(:first_name, :last_name, :api_key_digest)
    end
  end

  def user_json(user)
    {
      uid: user.uid,
      firstName: user.first_name,
      lastName: user.last_name,
      email: user.email,
      isAdmin: user.is_admin,
      isActive: user.is_active,
      canManageAllControlledVocabularies: user.can_manage_all_controlled_vocabularies,
      accountType: user.account_type,
      apiKeyDigest: user.api_key_digest,
    }
  end

  def user_project_permissions_json(user)
    user.project_permissions.includes(:project).order('projects.display_label').map do |pp|
      {
        id: pp.id,
        projectId: pp.project_id,
        projectStringKey: pp.project.string_key,
        projectDisplayLabel: pp.project.display_label,
        canRead: pp.can_read,
        canCreate: pp.can_create,
        canUpdate: pp.can_update,
        canDelete: pp.can_delete,
        canPublish: pp.can_publish,
        isProjectAdmin: pp.is_project_admin
      }
    end
  end
end