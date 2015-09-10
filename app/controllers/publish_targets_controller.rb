class PublishTargetsController < ApplicationController

  before_action :require_hyacinth_admin!
  before_action :set_publish_target, only: [:show, :edit, :update, :destroy]
  before_action :set_contextual_nav_options

  # GET /publish_targets
  # GET /publish_targets.json
  def index
    @publish_targets = PublishTarget.all
  end

  # GET /publish_targets/1
  def show
    respond_to do |format|
      format.html { redirect_to edit_publish_target_path(@publish_target) }
    end
  end

  # GET /publish_targets/new
  def new
    @publish_target = PublishTarget.new
  end

  # GET /publish_targets/1/edit/:type
  def edit
  end

  # POST /publish_targets
  # POST /publish_targets.json
  def create
    @publish_target = PublishTarget.new(publish_target_params)

    respond_to do |format|
      if @publish_target.save
        format.html { redirect_to edit_publish_target_path(@publish_target), notice: 'Publish Target was successfully created.' }
        format.json { render action: 'show', status: :created, location: @publish_target }
      else
        format.html { render action: 'new' }
        format.json { render json: @publish_target.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /publish_targets/1
  # PATCH/PUT /publish_targets/1.json
  def update

    respond_to do |format|
      if @publish_target.update(publish_target_params)
        format.html {
          redirect_to edit_publish_target_path(@publish_target), notice: 'Publish Target was successfully updated.'
        }
        format.json { head :no_content }
      else
        format.html {
          render action: 'edit'
        }
        format.json { render json: @publish_target.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /publish_targets/1
  # DELETE /publish_targets/1.json
  def destroy
    @publish_target.destroy
    respond_to do |format|
      format.html { redirect_to publish_targets_url }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_publish_target
    @publish_target = PublishTarget.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def publish_target_params
    params.require(:publish_target).permit(
      :id, :display_label, :string_key, :publish_url, :api_key
    )
  end

  def set_contextual_nav_options

    if params[:action] == 'index'
      @contextual_nav_options['nav_title']['label'] =  'Publish Targets'.html_safe
    else
      @contextual_nav_options['nav_title']['label'] =  '&laquo; Back to Publish Targets'.html_safe
      @contextual_nav_options['nav_title']['url'] = publish_targets_path
    end



    case params[:action]
    when 'index'
      @contextual_nav_options['nav_items'].push(label: 'Add New Publish Target', url: new_publish_target_path) if current_user.is_admin?
    when 'edit', 'update'
      @contextual_nav_options['nav_items'].push(label: 'Delete This Publish Target', url: publish_target_path(@publish_target.id), options: {method: :delete, data: { confirm: 'Are you sure you want to delete this Publish Target?' } }) if current_user.is_admin?
    end

  end

end
