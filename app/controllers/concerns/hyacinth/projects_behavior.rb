module Hyacinth::ProjectsBehavior
  # Use callbacks to share common setup or constraints between actions.
  def set_project
    @project ||= Project.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def project_params
    params.require(:project).permit(
      :id, :uri, :display_label, :string_key, :pid_generator_id, :full_path_to_custom_asset_directory,
      enabled_dynamic_fields_attributes: [:id, :digital_object_type_id, :dynamic_field_id, :default_value, :required, :hidden, :locked, :_destroy, fieldset_ids: []],
      project_permissions_attributes: [:id, :_destroy, :user_id, :can_create, :can_read, :can_update, :can_delete, :can_publish, :is_project_admin],
      enabled_publish_targets_attributes: [:id, :_destroy, :publish_target_id],
      fieldset_attributes: [:display_label, :project_id]
    )
  end
end
