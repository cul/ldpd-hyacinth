class Ability
  include CanCan::Ability

  def initialize(user)
    can do |action, subject_class, subject|
      action = action.to_sym

      if user.nil?
        false
      elsif user.admin?
        true
      elsif subject_class == User
        if subject && subject.id == user.id && [:edit, :update, :read, :show].include?(action)
          true
        else
          user.system_wide_permissions.include?(Permission::MANAGE_USERS)
        end
      elsif subject_class == Group
        if [:index, :show, :read].include?(action)
          true
        else
          user.system_wide_permissions.include?(Permission::MANAGE_GROUPS)
        end
      elsif subject_class == 'Vocabulary' # This is going to be a problem because it's not a real class
        user.system_wide_permissions.include?(Permission::MANAGE_VOCABULARIES)
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
    # elsif subject_class == Project # TODO: NEED TO ADD TESTS
    #   user.available_project_actions(subject.id).include?('manage')
    # end
  end
end
