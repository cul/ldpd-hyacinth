class Api::V2::PublishTargetsController < Api::V2::BaseController
  before_action :set_publish_target_by_string_key, only: [:show, :update, :destroy]

  # GET /api/v2/publish_targets
  def index
    authorize! :index, PublishTarget
    @publish_targets = PublishTarget.all.order(display_label: :asc)
    render json: { publish_targets: @publish_targets.map { |publish_target| publish_target_json(publish_target) } }
  end

  # GET /api/v2/publish_targets/:string_key
  def show
    authorize! :show, @publish_target
    render json: { publish_target: publish_target_json(@publish_target) }
  end

  # POST /api/v2/publish_targets
  # TODO: This endpoint should also accept an array of project ids to associate the publish target with those projects
  def create
    authorize! :create, PublishTarget
    @publish_target = PublishTarget.new(publish_target_params)

    if @publish_target.save
      render json: { publish_target: publish_target_json(@publish_target) }, status: :created
    else
      render json: { errors: format_errors(@publish_target.errors) }, status: :unprocessable_entity
    end
  end

  # PATCH /api/v2/publish_targets/:string_key
  # TODO: This endpoint should also accept an array of project ids to associate the publish target with those projects
  # Note: string_key is not updatable
  def update
    authorize! :update, @publish_target
    if @publish_target.update(publish_target_params)
      render json: { publish_target: publish_target_json(@publish_target) }
    else
      render json: { errors: format_errors(@publish_target.errors) }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v2/publish_targets/:string_key
  def destroy
    authorize! :destroy, @publish_target

    if @publish_target.digital_object_records.any?
      render json: { errors: { base: ['Cannot delete a publish target that has associated digital object records'] } }, status: :unprocessable_entity
      return
    end

    @publish_target.destroy
    render json: {}, status: :no_content
  end

  private

    def publish_target_params
      permitted = [:display_label, :publish_url, :api_key, project_ids: []]
      permitted << :string_key if action_name == 'create'
      params.require(:publish_target).permit(permitted)
    end

    def publish_target_json(publish_target)
      {
        stringKey: publish_target.string_key,
        displayLabel: publish_target.display_label,
        publishUrl: publish_target.publish_url,
        apiKey: publish_target.api_key,
        # ? Return an array of project string keys or of the full project details here?
        projects: publish_target.projects.map { |project| { id: project.id, stringKey: project.string_key, displayLabel: project.display_label } }
      }
    end

    def set_publish_target_by_string_key
      @publish_target = PublishTarget.find_by!(string_key: params[:string_key])
    end

    # Format errors for display in frontend forms
    # ? Move to the BaseController?
    def format_errors(errors)
      errors.messages.transform_keys { |key| key.to_s.camelize(:lower) }
    end
end
