module Api
  module V1
    class UsersController < ApplicationApiController
      before_action :ensure_json_request

      load_and_authorize_resource find_by: :uid, id_param: :uid, except: :authenticated

      # GET /users/authenticated
      def authenticated
        user = {
          first_name: current_user.first_name,
          last_name: current_user.last_name,
          uid: current_user.uid,
          rules: Ability.new(current_user).to_list
        }

        render json: user, status: :ok
      end

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
        if (permissions_attributes = calculate_permissions_attributes).present?
          @user.permissions_attributes = permissions_attributes
        end

        if @user.save
          render json: { user: @user }, status: :created
        else
          render json: errors(@user.errors.full_messages), status: :unprocessable_entity
        end
      end

      # PATCH /users/:uid
      def update
        new_user_params = user_params.to_h

        if (permissions_attributes = calculate_permissions_attributes).present?
          new_user_params[:permissions_attributes] = permissions_attributes
        end

        # Update password if one of the password fields is present in request.
        success = changing_password? ?
                    @user.update_with_password(new_user_params) :
                    @user.update_without_password(new_user_params)

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
          valid_params << :is_admin  if can? :manage, :all

          params.require(:user).permit(*valid_params)
        end

        def permission_params
          values = can?(:manage, @user) ? params.require(:user).permit(permissions: []).to_h : {}
          values ? values.fetch('permissions', []) : []
        end

        def calculate_permissions_attributes
          new_permissions = permission_params.uniq
          permission_attributes = []

          if new_permissions.present?
            permission_attributes = @user.permissions.where(subject: nil, subject_id: nil).map do |perm|
              if new_permissions.include?(perm.action)
                new_permissions.delete(perm.action)
                { id: perm.id, action: perm.action }
              else
                { id: perm.id, _destroy: true }
              end
            end

            permission_attributes.concat new_permissions.map { |new_perm| { action: new_perm } }
          end

          permission_attributes
        end
    end
  end
end
