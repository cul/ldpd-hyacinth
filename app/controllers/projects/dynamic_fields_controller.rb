module Projects
  class DynamicFieldsController < SubresourceController
    include Hyacinth::ProjectsBehavior

    before_action :set_project
    before_action :require_appropriate_permissions!
    before_action :set_contextual_nav_options

    # GET /projects/1/dynamic_fields/edit?digital_object_type_id=1
    def edit
      @digital_object_type = DigitalObjectType.find(params[:digital_object_type_id])
    end

    # PATCH/PUT /projects/1/dynamic_fields?digital_object_type_id=1
    def update
      if @project.update(project_params)
        redirect_to edit_enabled_dynamic_fields_path(id: @project.id, digital_object_type_id: params[:digital_object_type_id]), notice: 'Your changes have been saved.'
      else
        render action: 'edit'
      end
    end

    def set_contextual_nav_options
      @contextual_nav_options['nav_title']['label'] =  '&laquo; Back to Projects'.html_safe
      @contextual_nav_options['nav_title']['url'] = projects_path
    end

    private

    # Never trust parameters from the scary internet, only allow the white list through.
    def project_params
      params.require(:project).permit(
        :id, :display_label, :string_key, :pid_generator_id, :full_path_to_custom_asset_directory,
        :enabled_dynamic_fields_attributes => [ :id, :digital_object_type_id, :dynamic_field_id, :default_value, :required, :hidden, :locked, :_destroy, :fieldset_ids => [] ],
        :project_permissions_attributes => [:id, :_destroy, :user_id, :can_create, :can_read, :can_update, :can_delete, :can_publish, :is_project_admin],
        :enabled_publish_targets_attributes => [:id, :_destroy, :publish_target_id],
        :fieldset_attributes => [:display_label, :project_id]
      )
    end

  end
end
