class Api::V2::PublishTargetsController < Api::V2::BaseController
  before_action :set_publish_target_by_string_key, only: [:show, :update, :destroy]

  # GET /api/v2/publish_targets
  def index
    authorize! :index, PublishTarget
    @publish_targets = PublishTarget.all.order(display_label: :asc)
    render_camelized_json({ publish_targets: @publish_targets.map { |publish_target| publish_target_json(publish_target) } })
  end

  # GET /api/v2/publish_targets/:string_key
  def show
    authorize! :show, @publish_target
    render_camelized_json({ publish_target: publish_target_json(@publish_target) })
  end

  # POST /api/v2/publish_targets
  def create
    authorize! :create, PublishTarget
    @publish_target = PublishTarget.new(publish_target_params)

    if @publish_target.save
      render_camelized_json({ publish_target: publish_target_json(@publish_target) }, status: :created)
    else
      render_camelized_json({ errors: format_errors(@publish_target.errors) }, status: :unprocessable_entity)
    end
  end

  # PATCH /api/v2/publish_targets/:string_key
  def update
    authorize! :update, @publish_target
    if @publish_target.update(publish_target_params)
      render_camelized_json({ publish_target: publish_target_json(@publish_target) })
    else
      render_camelized_json({ errors: format_errors(@publish_target.errors) }, status: :unprocessable_entity)
    end
  end

  # DELETE /api/v2/publish_targets/:string_key
  def destroy
    authorize! :destroy, @publish_target

    if @publish_target.digital_object_records.any?
      render_camelized_json({ errors: { base: ['Cannot delete a publish target that has associated digital object records'] } }, status: :unprocessable_entity)
      return
    end

    @publish_target.destroy
    render_camelized_json({}, status: :no_content)
  end

  private

    def publish_target_params
      permitted = [:display_label, :publish_url, :api_key, project_ids: []]
      permitted << :string_key if action_name == 'create'
      params.require(:publish_target).permit(permitted)
    end

    def publish_target_json(publish_target)
      {
        id: publish_target.id,
        string_key: publish_target.string_key,
        display_label: publish_target.display_label,
        publish_url: publish_target.publish_url,
        api_key: "#{publish_target.api_key[0, 2]}...#{publish_target.api_key[-2..-1]}",
        projects: publish_target.projects.map { |project| { id: project.id, string_key: project.string_key, display_label: project.display_label } }
      }
    end

    def set_publish_target_by_string_key
      @publish_target = PublishTarget.find_by!(string_key: params[:string_key])
    end
end
