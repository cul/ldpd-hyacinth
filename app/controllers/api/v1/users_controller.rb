module Api
  module V1
    class UsersController < ApplicationApiController
      before_action :ensure_json_request

      load_and_authorize_resource find_by: :uid, id_param: :uid

      # GET /users
      def index
        users = User.all.order(:last_name)
        render json: { users: users }, status: :ok
      end

      # GET /users/:uid
      def show
        if @user
          render json: { user: @user }, status: :ok
        else
          render json: errors('Not Found'), status: :not_found
        end
      end

      # POST /users
      def create
        if @user.save
          render json: { user: @user }, status: :created
        else
          render json: errors(@user.errors.full_messages), status: :unprocessable_entity
        end
      end

      # PATCH /users/:uid
      def update
        # Update password if one of the password fields is present in request.
        success = changing_password? ?
                    @user.update_with_password(user_params) :
                    @user.update_without_password(user_params)

        if success
          render json: { user: @user }, status: 200
        else
          render json: errors(@user.errors.full_messages), status: :unprocessable_entity
        end
      end

      private

        def changing_password?
          [:current_password, :password, :password_confirmation].any? { |k| user_params.include?(k) && user_params[k].present? }
        end

        def user_params
          valid_params = [:first_name, :last_name, :email, :current_password, :password, :password_confirmation]
          valid_params << :is_active if can? :manage, @user

          params.require(:user).permit(*valid_params)
        end
    end
  end
end
