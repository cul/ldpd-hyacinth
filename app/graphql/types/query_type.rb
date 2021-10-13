# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    # Add root-level fields here.
    # They will be entry points for queries on your schema.

    field :authenticated_user, AuthenticatedUserType, null: true do
      description 'Logged-in user'
    end

    field :users, [UserType], null: true do
      description 'List of all users'
    end

    field :user, UserType, null: true do
      description "Find a user by ID"
      argument :id, ID, required: true
    end

    field :publish_targets, [PublishTargetType], null: true do
      description "List of all publish targets"
    end

    field :publish_target, PublishTargetType, null: true do
      argument :string_key, ID, required: true
    end

    field :project, ProjectType, null: true do
      argument :string_key, ID, required: true
    end

    field :projects, [ProjectType], null: true do
      description "List of all projects"
    end

    field :digital_objects, DigitalObject::SearchRecord.results_type, null: true, extensions: [Types::Extensions::SolrSearch, Types::Extensions::MapToDigitalObjectSearchRecord] do
      description "List and searches all digital objects"
      argument :order_by, Inputs::DigitalObject::OrderByInput, required: false, default_value: { field: 'score', direction: 'desc' }
    end

    field :facet_values, Facets::ValueTypeResults, null: true do
      description "List facet values for a specified facet in a search context"
      argument :field_name, String, required: true
      argument :limit, "Types::Scalar::Limit", required: true
      argument :offset, "Types::Scalar::Offset", required: false
      argument :order_by, Inputs::FacetValues::OrderByInput, required: false, default_value: { field: 'count', direction: 'asc' }
      argument :search_params, Types::SearchAttributes, required: false
    end

    field :digital_object, DigitalObjectInterface, null: true do
      argument :id, ID, required: true
    end

    field :permission_actions, PermissionActionsType, null: true do
      description 'Information about available project permission actions.'
    end

    field :vocabulary, VocabularyType, null: true do
      argument :string_key, ID, required: true
    end

    field :vocabularies, VocabularyType.results_type, null: true, extensions: [Types::Extensions::Paginate] do
      description "List of all vocabularies"
    end

    field :dynamic_field_categories, [DynamicFieldCategoryType], null: true do
      description 'List of all dynamic field categories'
      argument :metadata_form, Enums::MetadataFormEnum, required: false
    end

    field :dynamic_field_graph, DynamicFieldGraphType, null: true do
      description 'Graph of all dynamic field definitions'
      argument :metadata_form, Enums::MetadataFormEnum, required: false
    end

    field :dynamic_field_category, DynamicFieldCategoryType, null: true do
      argument :id, ID, required: true
    end

    field :dynamic_field_group, DynamicFieldGroupType, null: true do
      argument :id, ID, required: true
    end

    field :dynamic_field, DynamicFieldType, null: true do
      argument :id, ID, required: true
    end

    field :enabled_dynamic_fields, [EnabledDynamicFieldType], null: true do
      argument :project, Inputs::StringKey, required: true
      argument :digital_object_type, Enums::DigitalObjectTypeEnum, required: true
    end

    field :field_export_profiles, [FieldExportProfileType], null: true do
      description "List of all field export profiles"
    end

    field :field_export_profile, FieldExportProfileType, null: true do
      argument :id, ID, required: true
    end

    field :batch_exports, BatchExportType.results_type, null: false, extensions: [Types::Extensions::Paginate] do
      description 'List of BatchExports visible to the logged-in user, ordered from most recent to least recent.'
    end

    field :batch_imports, BatchImportType.results_type, null: false, extensions: [Types::Extensions::Paginate] do
      description 'List of BatchImport visible to the logged-in user, ordered from most recent to least recent.'
    end

    field :batch_import, BatchImportType, null: true do
      description 'A batch import'
      argument :id, ID, required: true
    end

    def digital_objects(**arguments)
      search_params = arguments[:search_params] ? arguments[:search_params].prepare : {}

      # Generating all facets.
      core_facets = ['digital_object_type_ssi', 'projects_ssim', 'rights_category_present_bi'] # Non-Dynamic-Field facets
      df_facets = Hyacinth::DigitalObject::Facets.all_solr_keys # Generate solr keys for all dynamic fields where is_facetable is true.

      search_params['facet_on'] = core_facets.concat(df_facets)

      Hyacinth::Config.digital_object_search_adapter.search(search_params, context[:current_user]) do |solr_params|
        solr_params.rows(arguments[:limit])
        solr_params.start(arguments[:offset])
        solr_params.sort(arguments[:order_by][:field], arguments[:order_by][:direction]) if arguments[:order_by]
      end
    end

    def digital_object(id:)
      digital_object = ::DigitalObject.find_by_uid!(id)
      ability.authorize!(:read, digital_object)
      digital_object
    end

    def facet_values(**arguments)
      search_params = arguments[:search_params] ? arguments[:search_params].prepare : {}

      Hyacinth::Config.digital_object_search_adapter.search(search_params, context[:current_user]) do |solr_params|
        solr_params.rows(0)
        solr_params.facet_on(arguments[:field_name]) do |facet_params|
          facet_params.rows(arguments[:limit])
          facet_params.start(arguments[:offset])
          facet_params.sort(arguments[:order_by][:field], arguments[:order_by][:direction]) if arguments[:order_by]
          facet_params.with_statistics!
        end
      end
    end

    def vocabulary(string_key:)
      vocabulary = Vocabulary.find_by!(string_key: string_key)
      ability.authorize!(:read, vocabulary)
      vocabulary
    end

    def vocabularies(**_arguments)
      ability.authorize!(:read, Vocabulary)
      Vocabulary.accessible_by(ability).order(:label)
    end

    def dynamic_field_categories(metadata_form: nil)
      ability.authorize!(:read, DynamicFieldCategory)
      categories = DynamicFieldCategory.order(:sort_order).includes(:dynamic_field_groups)
      metadata_form ? categories.where(metadata_form: metadata_form) : categories
    end

    def dynamic_field_graph(metadata_form: nil)
      ability.authorize!(:read, DynamicFieldCategory)
      categories = DynamicFieldCategory.order(:sort_order).includes(:dynamic_field_groups)
      categories = categories.where(metadata_form: metadata_form) if metadata_form
      categories = categories.map { |category| category.as_json(camelize: true) }
      { dynamic_field_categories: categories }
    end

    def dynamic_field_category(id:)
      dynamic_field_category = DynamicFieldCategory.find(id)
      ability.authorize!(:read, dynamic_field_category)
      dynamic_field_category
    end

    def dynamic_field_group(id:)
      dynamic_field_group = DynamicFieldGroup.find(id)
      ability.authorize!(:read, dynamic_field_group)
      dynamic_field_group
    end

    def dynamic_field(id:)
      dynamic_field = DynamicField.find(id)
      ability.authorize!(:read, dynamic_field)
      dynamic_field
    end

    def enabled_dynamic_fields(project:, digital_object_type:)
      project = Project.find_by!(project.to_h)
      ability.authorize!(:read, project)
      # TODO: Move this SQL query and parsing to a model method (HYACINTH-646)
      join_query = "SELECT dynamic_fields.id AS df_id, enabled_dynamic_fields.* FROM dynamic_fields"\
                   " LEFT OUTER JOIN enabled_dynamic_fields ON enabled_dynamic_fields.dynamic_field_id = dynamic_fields.id"\
                   " AND enabled_dynamic_fields.project_id = #{project.id} AND enabled_dynamic_fields.digital_object_type = '#{digital_object_type}'"
      field_sets = project.field_sets.where(enabled_dynamic_fields: { digital_object_type: digital_object_type }).includes(:enabled_dynamic_fields)
      DynamicField.connection.select_all(join_query).map do |result|
        dynamic_field_id = result.delete('df_id')
        edf = result['id'] ? EnabledDynamicField.new(result) : EnabledDynamicField.new(digital_object_type: digital_object_type)
        edf.project = project
        edf.dynamic_field = DynamicField.new(id: dynamic_field_id)
        edf.field_sets = field_sets.select { |fs| fs.enabled_dynamic_field_ids.include?(result['id']) } if result['id']
        edf
      end
    end

    def field_export_profiles
      ability.authorize!(:read, FieldExportProfile)
      FieldExportProfile.order(:name)
    end

    def field_export_profile(id:)
      field_export_profile = FieldExportProfile.find(id)
      ability.authorize!(:read, field_export_profile)
      field_export_profile
    end

    def project(string_key:)
      project = Project.find_by!(string_key: string_key)
      ability.authorize!(:read, project)
      project
    end

    def projects
      ability.authorize!(:read, Project)
      Project.accessible_by(ability)
    end

    def publish_targets
      ability.authorize!(:read, PublishTarget)
      PublishTarget.accessible_by(ability).order(:string_key)
    end

    def publish_target(string_key:)
      publish_target = PublishTarget.find_by!(string_key: string_key)
      ability.authorize!(:read, publish_target)
      publish_target
    end

    def user(id:)
      user = User.find_by!(uid: id)
      ability.authorize!(:read, user)
      user
    end

    def users
      ability.authorize!(:index, User)
      User.accessible_by(ability).order(:sort_name)
    end

    def permission_actions
      {
        project_actions: Permission::PROJECT_ACTIONS
      }
    end

    def batch_exports
      BatchExport.accessible_by(ability).order(id: :desc)
    end

    def batch_imports
      BatchImport.accessible_by(ability).order(id: :desc)
    end

    def batch_import(id:)
      batch_import = BatchImport.find(id)
      ability.authorize!(:read, batch_import)
      batch_import
    end

    def authenticated_user
      context[:current_user]
    end
  end
end
