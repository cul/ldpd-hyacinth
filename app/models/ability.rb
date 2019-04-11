class Ability
  include CanCan::Ability

  def initialize(user)
    return if user.nil?

    if user.admin?
      can :manage, :all
    else
      system_permissions, project_permissions = calculate_permissions(user)

      # Permissions all users get
      can [:show, :update], User, id: user.id
      can [:index, :show], Group
      can [:index, :show, :create], :term
      # can :index, Project, everyone should be able to see a list of projects they have access to

      # System Wide Permissions
      assign_system_wide_permissions(system_permissions)

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

  def assign_system_wide_permissions(system_permissions)
    system_permissions.each do |role|
      case role
      when Permission::MANAGE_USERS
        can :manage, User
      when Permission::MANAGE_GROUPS
        can :manage, Group
      when Permission::MANAGE_VOCABULARIES
        can :manage, :vocabulary
        can :manage, :term
        can :manage, :custom_field
      when Permission::READ_ALL_DIGITAL_OBJECTS, Permission::MANAGE_ALL_DIGITAL_OBJECTS
        can :show, [Project, PublishTarget, FieldSet]
      end
    end
  end

  def calculate_permissions(user)
    project_permissions = {}
    system_permissions = []

    user.permissions.each do |p|
      if p.subject.blank? && p.subject_id.blank?
        system_permissions << p.action
      elsif p.subject == Project.to_s && Permission::PROJECT_ACTIONS.include?(p.action)
        id = p.subject_id.to_i

        project_permissions[id] = []        unless project_permissions.key?(id)
        project_permissions[id] << p.action unless project_permissions[id].include?(p.action)
      end
    end

    [system_permissions.uniq, project_permissions]
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
