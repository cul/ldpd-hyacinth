module Api
  module V1
    class GroupsController < ApplicationApiController
      # TODO: Need to check that current user is allowed to make the requested changes.

      before_action :ensure_json_request

      # GET /groups
      def index
        groups = Group.all
        render json: groups, status: 200
      end

      # GET /groups/:string_key
      def show
        group = Group.find(string_key: params[:string_key])
        if group
          render json: group, status: 200
        else
          render json: errors('Not Found'), status: :not_found
        end
      end

      # POST /groups/:string_key
      def create
        group = Group.new(create_params)
        if group.save
          render json: group, status: 201
        else
          render json: errors(group.errors.full_messages), status: 500
        end
      end

      # PATCH /groups/:string_key
      def update # Adding new users
        group = Group.find_by(string_key: params[:string_key])

        # TODO: There are more efficient ways to do this.
        user_ids = update_params[:user_uids].map { |uid| User.find_by(uid: uid).id }
        group.user_ids = user_ids

        if group.save
          render json: group, status: 200
        else
          render json: errors(group.errors.full_messages), status: 500
        end
      end

      # DELETE /groups/:string_key
      def destroy
        group = Group.find_by(string_key: params[:string_key])

        if group.nil?
          render json: errors('Not Found'), status: 404
        elsif group.destroy
          head :no_content
        else
          render json: errors('Deleting was unsuccessful.'), status: 500
        end
      end

      private

        def create_params
          params.permit(:string_key)
        end

        def update_params
          params.permit(user_uids: []) # TODO: add `permissions: []`
        end
    end
  end
end
