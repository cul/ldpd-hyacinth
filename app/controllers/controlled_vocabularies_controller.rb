class ControlledVocabulariesController < ApplicationController
  before_action :set_controlled_vocabulary, only: [:show, :edit, :update, :destroy, :terms, :term_additional_fields]
  before_action :require_appropriate_permissions!
  before_action :set_contextual_nav_options

  # GET /controlled_vocabularies
  # GET /controlled_vocabularies.json
  def index
    # Get all registered ControlledVocabularies
    @controlled_vocabularies = ControlledVocabulary.all.order(:string_key)

    # Also get additional controlled vocabularies from UriService that haven't been registered
    controlled_vocabulary_string_keys = @controlled_vocabularies.map(&:string_key)
    @additional_uri_service_controlled_vocabularies = UriService.client.list_vocabularies(1000) # Ridiculously high limit to show all
    @additional_uri_service_controlled_vocabularies.delete_if { |uri_service_vocabulary| controlled_vocabulary_string_keys.include?(uri_service_vocabulary['string_key']) }
  end

  # GET /controlled_vocabularies/1
  # GET /controlled_vocabularies/1.json
  def show
  end

  # GET /controlled_vocabularies/new
  def new
    @controlled_vocabulary = ControlledVocabulary.new
    @controlled_vocabulary.string_key = params[:string_key] if params[:string_key].present?
    @controlled_vocabulary.display_label = params[:display_label] if params[:display_label].present?
  end

  # GET /controlled_vocabularies/1/edit
  def edit
  end

  # POST /controlled_vocabularies
  # POST /controlled_vocabularies.json
  def create
    @controlled_vocabulary = ControlledVocabulary.new(controlled_vocabulary_params)

    respond_to do |format|
      if @controlled_vocabulary.save
        format.html { redirect_to edit_controlled_vocabulary_path(@controlled_vocabulary), notice: 'Controlled vocabulary was successfully created.' }
      else
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT /controlled_vocabularies/1
  # PATCH/PUT /controlled_vocabularies/1.json
  def update
    respond_to do |format|
      if @controlled_vocabulary.update(controlled_vocabulary_params)
        format.html { redirect_to edit_controlled_vocabulary_path(@controlled_vocabulary), notice: 'Controlled vocabulary was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @controlled_vocabulary.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /controlled_vocabularies/1
  # DELETE /controlled_vocabularies/1.json
  def destroy
    @controlled_vocabulary.destroy
    respond_to do |format|
      format.html { redirect_to controlled_vocabularies_url }
      format.json { head :no_content }
    end
  end

  def terms
    @page = params.fetch(:page, 1).to_i

    if request.format == 'text/html'
      @per_page = params.fetch(:per_page, 20).to_i
    else
      @per_page = params.fetch(:per_page, 5).to_i
    end
    @per_page = 5 if @per_page < 5 # Show at least 5 terms per page

    if params[:q].blank?
      @terms = UriService.client.list_terms(@controlled_vocabulary.string_key, @per_page + 1, ((@page - 1) * @per_page))
    else
      @terms = UriService.client.find_terms_by_query(@controlled_vocabulary.string_key, params[:q], @per_page + 1, ((@page - 1) * @per_page))
    end

    respond_to do |format|
      # Render normal html view
      format.html

      format.json do
        render json: {
          terms: @terms[0..(@per_page - 1)],
          more_available: (@terms.length > @per_page),
          current_user_can_add_terms: current_user.can_manage_controlled_vocabulary_terms?(@controlled_vocabulary)
        }
      end
    end
  end

  def term_additional_fields
    respond_to do |format|
      format.json { render json: TERM_ADDITIONAL_FIELDS.fetch(@controlled_vocabulary.string_key, {}) }
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_controlled_vocabulary
      if params[:id].match?(/[0-9]+/)
        @controlled_vocabulary = ControlledVocabulary.find(params[:id])
      else
        @controlled_vocabulary = ControlledVocabulary.find_by(string_key: params[:id])
      end

      raise ActionController::RoutingError, 'Controlled vocabulary not found' if @controlled_vocabulary.nil?
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def controlled_vocabulary_params
      params.require(:controlled_vocabulary).permit(:string_key, :display_label, :require_controlled_vocabulary_manager_permission)
    end

    def set_contextual_nav_options
      case params[:action]
      when 'index'
        @contextual_nav_options['nav_title']['label'] = 'Controlled Vocabularies'.html_safe
      when 'search'
        @contextual_nav_options['nav_title']['label'] = '&laquo; Back to Controlled Vocabularies'.html_safe
        @contextual_nav_options['nav_title']['url'] = controlled_vocabularies_path
      when 'new'
        @contextual_nav_options['nav_title']['label'] = '&laquo; Back to Controlled Vocabularies'.html_safe
        @contextual_nav_options['nav_title']['url'] = controlled_vocabularies_path
      when 'edit', 'update'
        @contextual_nav_options['nav_title']['label'] = '&laquo; Back to Controlled Vocabularies'.html_safe
        @contextual_nav_options['nav_title']['url'] = controlled_vocabularies_path

        @contextual_nav_options['nav_items'].push(label: 'Manage Terms', url: terms_controlled_vocabulary_path(@controlled_vocabulary))
      when 'terms'
        @contextual_nav_options['nav_title']['label'] =  '&laquo; Back to Controlled Vocabularies'.html_safe
        @contextual_nav_options['nav_title']['url'] = controlled_vocabularies_path
      end
      set_admin_contextual_nav_options
      set_manager_contextual_nav_options
    end

    def set_admin_contextual_nav_options
      return unless current_user.admin?
      case params[:action]
      when 'index'
        @contextual_nav_options['nav_items'].push(label: 'Add New Controlled Vocabulary', url: new_controlled_vocabulary_path)
      when 'edit', 'update'
        @contextual_nav_options['nav_items'].push(label: 'Delete This Controlled Vocabulary', url: controlled_vocabulary_path(@controlled_vocabulary), options: { method: :delete, data: { confirm: 'Are you sure you want to delete this Controlled Vocabulary?' } })
      end
    end

    def set_manager_contextual_nav_options
      return unless current_user.can_manage_controlled_vocabulary_terms?(@controlled_vocabulary)
      @contextual_nav_options['nav_items'].push(label: 'New Term', url: new_term_path(controlled_vocabulary_string_key: @controlled_vocabulary.string_key)) if params[:action] == 'terms'
    end

    def require_appropriate_permissions!
      case params[:action]
      when 'index', 'terms', 'term_additional_fields'
        # Do nothing
      else
        require_hyacinth_admin!
      end
    end
end
