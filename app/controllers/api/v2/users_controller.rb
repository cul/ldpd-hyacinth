class Api::V2::UsersController < Api::V2::BaseController
  before_action :set_user_by_uid, only: [:show, :update]

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
          render json: { user: current_user }
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
    if @user.update(user_params)
      render json: { user: user_json(@user) }
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
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
        :is_admin, :can_manage_all_controlled_vocabularies, :is_active, :account_type
      )
    else
      params.require(:user).permit(:first_name, :last_name)
    end
  end

  def user_json(user)
    {
      uid: user.uid,
      first_name: user.first_name,
      last_name: user.last_name,
      email: user.email,
      is_admin: user.is_admin,
      is_active: user.is_active,
      can_manage_all_controlled_vocabularies: user.can_manage_all_controlled_vocabularies,
      account_type: user.account_type,
    }
  end
end