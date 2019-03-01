module Api
  module V1
    class UsersController < ApplicationApiController
      before_action :ensure_json_request

      # TODO: Need to check that current user is allowed to make the requested changes.

      load_resource find_by: :uid, id_param: :uid

      before_action :ensure_json_request

      # GET /users
      def index
        users = User.all.order(:last_name)
        render json: users, status: :ok
      end

      # GET /users/:uid
      def show
        if @user
          render json: @user, status: :ok
        else
          render json: errors('Not Found'), status: :not_found
        end
      end

      # POST /users
      def create
        if @user.save
          render json: @user, status: :created
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
          render json: @user, status: 200
        else
          render json: errors(@user.errors.full_messages), status: :unprocessable_entity
        end
      end

      private

        def changing_password?
          [:current_password, :password, :password_confirmation].any? { |k| user_params.include?(k) }
        end

        def user_params
          params.permit(:first_name, :last_name, :email, :current_password, :password, :password_confirmation, :is_active)
        end
    end
  end
end
