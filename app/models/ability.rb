# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    return if user.nil?

    # Going forward we should only be using the following actions for CRUD operations: :read, :create,
    # :update, and :destroy. We shouldn't be using :show, :index, :new, or :edit when defining
    # actions or checking abilities. These aliases were made for RESTful actions and since we are
    # moving away from that we no longer need to use them.

    if user.admin?
      can :manage, :all
    else
      system_permissions, project_permissions = calculate_permissions(user)

      # Permissions all users get
      can [:read, :update], User, id: user.id
      can [:read, :update], User, uid: user.uid
      can [:read, :create], Term
      can :read, PublishTarget        # sensitive information is filtered for non-admins
      can :read, Vocabulary           # Need to allow this because Terms are nested under vocabularies
      can :read, DynamicFieldCategory # Need to allow this so we can render EnabledDynamicField pages.

      can :create, BatchExport # All users can create BatchExports
      can [:read, :destroy], BatchExport, user_id: user.id

      can :create, BatchImport # All users can create BatchImports
      can [:read, :update, :destroy], BatchImport, user_id: user.id

      # System Wide Permissions
      assign_system_wide_permissions(system_permissions)

      # Project Based Permissions
      project_permissions.each do |project_id, actions|
        project_string_key = Project.find(project_id).string_key

        can :read, Project, id: project_id
        can :read, Project, string_key: project_string_key

        can :read, FieldSet, project_id: project_id
        can :read, FieldSet, project: { string_key: project_string_key }

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
        can :manage, Vocabulary
        can :manage, Term
        can :manage, :custom_field
      when Permission::READ_ALL_DIGITAL_OBJECTS
        can :read, [Project, FieldSet]
        can :read, DigitalObject
        can :read_objects, Project
      when Permission::MANAGE_ALL_DIGITAL_OBJECTS
        can :read, [Project, FieldSet]
        can :manage, DigitalObject
        can [:read_objects, :create_objects, :update_objects, :assess_rights, :delete_objects, :publish_objects], Project
      when Permission::MANAGE_RESOURCE_REQUESTS
        can :manage, ResourceRequest
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
    # Skipping rules that only contain a block.
    rules.reject(&:only_block?).map do |rule|
      rule.only_block?
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

      object[:conditions] = rule.conditions
      object[:inverted] = !rule.base_behavior
      object
    end
  end

  def manage(project_id, project_string_key)
    # Allow project managers to read all users so they can assign users to projects
    can :read, User

    can :update, Project, id: project_id
    can :update, Project, string_key: project_string_key

    can [:read, :create, :update, :destroy], FieldSet, project_id: project_id
    can [:read, :create, :update, :destroy], FieldSet, project: { string_key: project_string_key }
  end

  def read_objects(project_id, project_string_key)
    # assign for digital objects in the project
    can :read_objects, Project, { id: project_id }
    can :read_objects, Project, { string_key: project_string_key }
    # and in the context of a specific object where applicable
    can :read, DigitalObject do |digital_object|
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
    can :update, DigitalObject do |digital_object|
      digital_object.projects.detect { |p| p.id.eql?(project_id) || p.string_key.eql?(project_string_key) }
    end
  end

  def delete_objects(project_id, project_string_key)
    # assign for digital objects in the project
    can :delete_objects, Project, { id: project_id }
    can :delete_objects, Project, { string_key: project_string_key }
    # and in the context of a specific object where applicable
    can :destroy, DigitalObject do |digital_object|
      digital_object.projects.detect { |p| p.id.eql?(project_id) || p.string_key.eql?(project_string_key) }
    end
  end

  def publish_objects(project_id, project_string_key)
    # assign for digital objects in the project
    can :publish_objects, Project, { id: project_id }
    can :publish_objects, Project, { string_key: project_string_key }
    # and in the context of a specific object where applicable
    can [:publish, :preserve], DigitalObject do |digital_object|
      digital_object.projects.detect { |p| p.id.eql?(project_id) || p.string_key.eql?(project_string_key) }
    end
  end

  def assess_rights(project_id, project_string_key)
    # assign for digital objects in the project
    can :assess_rights, Project, { id: project_id }
    can :assess_rights, Project, { string_key: project_string_key }
    # and in the context of a specific object where applicable
    can :update_rights, DigitalObject do |digital_object|
      digital_object.projects.detect { |p| p.id.eql?(project_id) || p.string_key.eql?(project_string_key) }
    end
  end
end
