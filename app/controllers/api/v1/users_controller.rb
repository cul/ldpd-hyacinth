module Api
  module V1
    class UsersController < ApplicationApiController
      # TODO: Need to check that current user is allowed to make the requested changes.

      before_action :ensure_json_request

      # GET /users
      def index
        users = User.all
        render json: users, status: 200
      end

      # GET /users/:uid
      def show
        user = User.find_by(uid: params[:uid])
        if user
          render json: user, status: 200
        else
          render json: errors('Not Found'), status: 404
        end
      end

      # POST /users
      def create
        user = User.new(user_params)

        if user.save
          render json: user, status: 201
        else
          render json: errors(user.errors.full_messages), status: 500
        end
      end

      # PATCH /users/:uid
      def update
        user = User.find_by(uid: params[:uid])

        if user.assign_attributes(user_params)
          render json: user, status: 200
        else
          render json: errors(user.errors.full_messages), status: 500
        end
      end

      private
        def user_params
          params.permit(:first_name, :last_name, :email, :password, :password_confirmation, :is_active)
        end
    end
  end
end
