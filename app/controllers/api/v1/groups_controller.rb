module Api
  module V1
    class GroupsController < ApplicationApiController
      before_action :ensure_json_request

      # TODO: override this, to include :permissions in sql query
      load_and_authorize_resource find_by: :string_key, id_param: :string_key

      # GET /groups
      def index
        groups = Group.all
        render json: { groups: groups }, status: :ok
      end

      # GET /groups/:string_key
      def show
        if @group
          render json: { group: @group }, status: :ok
        else
          render json: errors('Not Found'), status: :not_found
        end
      end

      # POST /groups/:string_key
      def create
        if @group.save
          render json: { group: @group }, status: :created
        else
          render json: errors(@group.errors.full_messages), status: :unprocessable_entity
        end
      end

      # PATCH /groups/:string_key
      def update
        errors = []

        # Update :is_admin property if current_user is an administrator.
        if can?(:manage, :all) && update_params.key?(:is_admin)
          @group.is_admin = update_params[:is_admin] if update_params.key?(:is_admin)
        end

        users = update_params.fetch(:user_ids, []).map do |uid|
          if user = User.find_by(uid: uid)
            user
          else
            errors << "User uid #{uid} not valid."
            nil
          end
        end

        new_permissions = update_params.fetch(:permissions, []).map do |perm|
          if Permission.valid_system_wide_permission?(perm)
            Permission.new(action: perm)
          else
            errors << "Permission #{perm} is not valid."
            nil
          end
        end

        if errors.blank?
          @group.permissions.where(subject: nil, subject_id: nil).destroy_all
          @group.permissions = new_permissions
          @group.users = []
          @group.users = users

          if @group.save
            render json: { group: @group }, status: :ok
          else
            render json: errors(@group.errors.full_messages), status: :unprocessable_entity
          end
        else
          render json: errors(errors), status: :unprocessable_entity
        end
      end

      # DELETE /groups/:string_key
      def destroy
        if @group.nil?
          render json: errors('Not Found'), status: :not_found
        elsif @group.destroy
          head :no_content
        else
          render json: errors('Deleting was unsuccessful.'), status: :unprocessable_entity
        end
      end

      private

        def create_params
          params.require(:group).permit(:string_key)
        end

        def update_params
          params.require(:group).permit(:is_admin, permissions: [], user_ids: [])
        end
    end
  end
end
