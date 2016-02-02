module Projects
  class SubresourceController < ApplicationController

    def require_appropriate_permissions!
      require_project_permission!(@project, :project_admin)
    end
    
  end
end
