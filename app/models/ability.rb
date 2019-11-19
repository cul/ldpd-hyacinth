class Ability
  include CanCan::Ability

  def initialize(user)
    return if user.nil?

    # Going forward we should only be using the following actions for CRUD operations: :read, :create,
    # :update, and :destroy. We shouldn't be using :show, :index, :new, or :edit when defining
    # actions or checking abilities. These aliases were made for RESTful actions and since we are
    # moving away from that, we should stop using them. Eventually, we should remove these aliases.

    if user.admin?
      can :manage, :all
    else
      system_permissions, project_permissions = calculate_permissions(user)

      # Permissions all users get
      can [:read, :update], User, id: user.id
      can [:read, :update], User, uid: user.uid
      can [:index, :show, :create], :term
      can [:index], DynamicFieldCategory # Need to allow this so we can render EnabledDynamicField pages.

      # System Wide Permissions
      assign_system_wide_permissions(system_permissions)

      # Project Based Permissions
      project_permissions.each do |project_id, actions|
        project_string_key = Project.find(project_id).string_key

        can [:index, :read], Project, id: project_id
        can [:index, :read], Project, string_key: project_string_key

        can :show, PublishTarget, project_id: project_id
        can :show, PublishTarget, project: { string_key: project_string_key }

        can :show, FieldSet, project_id: project_id
        can :show, FieldSet, project: { string_key: project_string_key }

        actions.each do |action|
          send action.to_sym, project_id, project_string_key
        end
      end
    end
  end

  def assign_system_wide_permissions(system_permissions)
    system_permissions.each do |role|
      case role
      when Permission::MANAGE_USERS
        can :manage, User
      when Permission::MANAGE_VOCABULARIES
        can :manage, :vocabulary
        can :manage, :term
        can :manage, :custom_field
      when Permission::READ_ALL_DIGITAL_OBJECTS, Permission::MANAGE_ALL_DIGITAL_OBJECTS
        can [:show, :index], [Project, PublishTarget, FieldSet]
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

  def to_list
    rules.map do |rule|
      object = { actions: rule.actions }
      object[:subject] = rule.subjects.map do |s|
        if s == :all
          s
        elsif s.is_a?(Symbol)
          s.to_s.camelcase
        else
          s.name
        end
      end

      object[:conditions] = rule.conditions unless rule.conditions.blank?
      object[:inverted] = true unless rule.base_behavior
      object
    end
  end

  def manage(project_id, project_string_key)
    can :update, Project, id: project_id
    can :update, Project, string_key: project_string_key

    can [:show, :create, :update, :destroy], FieldSet, project_id: project_id
    can [:show, :create, :update, :destroy], FieldSet, project: { string_key: project_string_key }
  end

  def read_objects(project_id, project_string_key)
    # assign for digital objects in the project
    can :read_objects, Project, { id: project_id }
    can :read_objects, Project, { string_key: project_string_key }
    # and in the context of a specific object where applicable
    can :read, DigitalObject::Base do |digital_object|
      digital_object.projects.detect { |p| p.id.eql?(project_id) }
    end
  end

  def create_objects(project_id, project_string_key)
    # assign for digital objects in the project
    can :create_objects, Project, { id: project_id }
    can :create_objects, Project, { string_key: project_string_key }
  end

  def update_objects(project_id, project_string_key)
    # assign for digital objects in the project
    can :update_objects, Project, { id: project_id }
    can :update_objects, Project, { string_key: project_string_key }
    # and in the context of a specific object where applicable
    can [:edit, :update], DigitalObject::Base do |digital_object|
      digital_object.projects.detect { |p| p.id.eql?(project_id) || p.string_key.eql?(project_string_key) }
    end
  end

  def delete_objects(project_id, project_string_key)
    # assign for digital objects in the project
    can :delete_objects, Project, { id: project_id }
    can :delete_objects, Project, { string_key: project_string_key }
    # and in the context of a specific object where applicable
    can :destroy, DigitalObject::Base do |digital_object|
      digital_object.projects.detect { |p| p.id.eql?(project_id) || p.string_key.eql?(project_string_key) }
    end
  end

  def publish_objects(project_id, project_string_key)
    # assign for digital objects in the project
    can :publish_objects, Project, { id: project_id }
    can :publish_objects, Project, { string_key: project_string_key }
    # and in the context of a specific object where applicable
    can [:publish, :preserve], DigitalObject::Base do |digital_object|
      digital_object.projects.detect { |p| p.id.eql?(project_id) || p.string_key.eql?(project_string_key) }
    end
  end
end
