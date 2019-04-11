class Ability
  include CanCan::Ability

  def initialize(user)
    return if user.nil?

    if user.admin?
      can :manage, :all
    else
      # Calculate Permissions
      project_permissions = {}
      system_permissions = []
      user.permissions.each do |p|
        if p.subject.blank? && p.subject_id.blank?
          system_permissions << p.action unless system_permissions.include?(p.action)
        elsif p.subject == Project.to_s && Permission::PROJECT_ACTIONS.include?(p.action)
          id = p.subject_id.to_i

          project_permissions[id] = []        unless project_permissions.key?(id)
          project_permissions[id] << p.action unless project_permissions[id].include?(p.action)
        end
      end

      # Permissions all users get
      can [:show, :update], User, id: user.id
      can [:index, :show], Group
      can [:index, :show, :create], :term
      # can :index, Project, everyone should be able to see a list of projects they have access to

      # System Wide Permissions
      can :manage, User  if system_permissions.include?(Permission::MANAGE_USERS)
      can :manage, Group if system_permissions.include?(Permission::MANAGE_GROUPS)

      if system_permissions.include?(Permission::MANAGE_VOCABULARIES)
        can :manage, :vocabulary
        can :manage, :term
        can :manage, :custom_field
      end

      can :show, [Project, PublishTarget, FieldSet] if system_permissions.include?(Permission::READ_ALL_DIGITAL_OBJECTS) || system_permissions.include?(Permission::MANAGE_ALL_DIGITAL_OBJECTS)

      # Project Based Permissions
      project_permissions.each do |project_id, actions|
        can :show, Project, id: project_id
        can :show, PublishTarget, project_id: project_id
        can :show, FieldSet, project_id: project_id

        if actions.include?('manage')
          can :update, Project, id: project_id
          can [:show, :create, :update, :destroy], FieldSet, project_id: project_id
        end
      end

      # Digital Object Permissions
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
