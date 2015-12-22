module Projects
  class SubresourceController < ApplicationController
    before_action :require_appropriate_permissions!

    def require_appropriate_permissions!

      case params[:action]
      when 'where_current_user_can_create'
          # Do nothing
      when 'index'
        unless current_user.is_project_admin_for_at_least_one_project?
          require_hyacinth_admin!
        end
      when 'edit', 'update', 'destroy',
        'edit_project_permissions', 'update_project_permissions',
        'edit_enabled_dynamic_fields', 'update_enabled_dynamic_fields', 'fieldsets'
        require_project_permission!(@project, :admin)
      else
        require_hyacinth_admin!
      end
    end

  end
end
