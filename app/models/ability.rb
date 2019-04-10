class Ability
  include CanCan::Ability

  # We are entirely taking over the permission calculation in order to make
  # it as efficient as possible.
  def initialize(user)
    can do |action, subject_class, subject|
      action = action.to_sym

      if user.nil?
        false
      elsif user.admin?
        true
      elsif subject_class == User
        evaluate_user_ability(user, action, subject)
      elsif subject_class == Group
        evaluate_group_ability(user, action, subject)
      elsif [Project].include? subject_class #, EnabledDynamicField, FieldSets
        project_id = subject_class == Project ? subject.id : subject.project.id

        if read_actions.include?(action)
          project_permissions(user, project_id).count.positive?
        else
          project_permissions(user, project_id).include?(:manage)
        end
      elsif subject_class == PublishTarget
        if read_actions.include?(action)
          project_permissions(user, subject&.project&.id).count.positive?
        end
      elsif subject_class == DigitalObject
        false
      end
    end

    # TODO: This logic needs to be added above once we have a proper Project model.
    # if subject_class == DigitalObject # TODO: NEED TO ADD TESTS
    #   if user.system_wide_permissions.include?(PERMISSION::MANAGE_ALL_DIGITAL_OBJECTS)
    #     true
    #   elsif action == :read && user.system_wide_permissions.include?(PERMISSION::READ_ALL_DIGITAL_OBJECTS)
    #     true
    #   else
    #     project_ids = subject.projects(&:id)
    #     project_actions = user.available_project_actions(project_ids)
    #
    #     project_actions.include?('manage') || project_actions.include?("#{action}_objects")
    #   end
    # end
  end

  def project_permissions(user, project_ids)
    allowed_actions = []
    system_permissions = user.system_wide_permissions
    allowed_actions << :read_object if system_permissions.include?(Permission::READ_ALL_DIGITAL_OBJECTS)

    if system_permissions.include?(Permission::MANAGE_ALL_DIGITAL_OBJECTS)
      allowed_actions.concat(
        [:read_objects, :create_objects, :update_objects, :delete_objects, :publish_objects]
      )
    end

    allowed_actions.concat(user.available_project_actions(project_ids)) if project_ids.present?
    allowed_actions.uniq
  end

  def read_actions
    [:index, :show, :read]
  end

  def evaluate_user_ability(user, action, subject)
    if subject && subject.id == user.id && [:edit, :update, :read, :show].include?(action)
      true
    else
      user.system_wide_permissions.include?(Permission::MANAGE_USERS)
    end
  end

  def evaluate_group_ability(user, action, subject)
    if read_actions.include?(action)
      true
    else
      user.system_wide_permissions.include?(Permission::MANAGE_GROUPS)
    end
  end
end
