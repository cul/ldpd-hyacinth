module Projects
  class FieldsetsController < SubresourceController
    include Hyacinth::ProjectsBehavior

    before_action :set_project, only: [:index, :new]
    before_action :set_contextual_nav_options
    before_action :set_fieldset, only: [:edit, :update, :destroy]

    def index
      # raise @project.inspect
      @fieldsets = Fieldset.where(project: @project)
    end

    # GET /projects/1/fieldsets/new
    def new
      @fieldset = Fieldset.new
      @fieldset.project = Project.find(@project)
    end

    # GET /projects/1/fieldsets/1/edit
    def edit
      # raise params.inspect
    end

    # POST /projects/1/fieldsets
    # POST /projects/1/fieldsets.json
    def create
      @fieldset = Fieldset.new(fieldset_params)

      respond_to do |format|
        if @fieldset.save
          format.html { redirect_to edit_project_fieldset_path(@fieldset), notice: 'Fieldset was successfully created.' }
        else
          format.html { render action: 'new' }
        end
      end
    end

    # PATCH/PUT /projects/1/fieldsets/1
    # PATCH/PUT /projects/1/fieldsets/1.json
    def update
      respond_to do |format|
        if @fieldset.update(fieldset_params)
          format.html { redirect_to edit_project_fieldset_path(@fieldset), notice: 'Fieldset was successfully updated.' }
        else
          format.html { render action: 'edit' }
        end
      end
    end

    # DELETE /projects/1/fieldsets/1
    # DELETE /projects/1/fieldsets/1.json
    def destroy
      project = @fieldset.project
      # raise params.inspect
      @fieldset.destroy
      respond_to do |format|
        format.html { redirect_to project_fieldsets_path(project) }
        format.json { head :no_content }
      end
    end

    def set_contextual_nav_options

      @contextual_nav_options['nav_title']['label'] = '&laquo; Back To Fieldsets'.html_safe

      case params[:action]
      when 'index'
        @contextual_nav_options['nav_title']['label'] = '&laquo; Back to Projects'.html_safe
        @contextual_nav_options['nav_title']['url'] = projects_path
        @contextual_nav_options['nav_items'].push(label: 'New Fieldset', url: new_project_fieldset_path(project_id: @project.id))
      when 'edit', 'update', 'show'
        @contextual_nav_options['nav_title']['url'] = project_fieldsets_path(set_fieldset.project)
        @contextual_nav_options['nav_items'].push(label: 'Delete This Fieldset',
                                                  url: project_fieldset_path(project: set_fieldset.project, fieldset: set_fieldset),
                                                  options: {method: :delete, data: { confirm: 'Are you sure you want to delete this Fieldset?' } })
      end
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_fieldset
      @fieldset ||= Fieldset.find(params[:id])
    end

  # Never trust parameters from the scary internet, only allow the white list through.
    def fieldset_params
      params.require(:fieldset).permit(:display_label, :project_id)
    end

  end
end
