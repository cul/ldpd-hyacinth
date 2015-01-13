class ControlledVocabulariesController < ApplicationController
  before_action :set_controlled_vocabulary, only: [:show, :edit, :update, :destroy]
  before_action :set_controlled_vocabular_by_id_or_string_key, only: [:authorized_terms]
  before_action :require_appropriate_permissions!
  before_action :set_contextual_nav_options

  # GET /controlled_vocabularies
  # GET /controlled_vocabularies.json
  def index
    # Standard view for listing controlled vocabularies
    @controlled_vocabularies = ControlledVocabulary.all
  end

  # GET or POST /controlled_vocabularies/search
  # GET or POST /controlled_vocabularies/search.json
  def search
    # TODO: Possibly use Solr for this kind of search?  This is for early testing purposes.

    if params[:page]
      page = params[:page].to_i
    else
      page = 1
    end

    if params[:uri_list].present?
      # Always return all results for a uri_list.  No paging, no limit, no sorting.
      @authorized_terms = AuthorizedTerm.includes(:controlled_vocabulary).where(
        value_uri: params[:uri_list]
      )
    else
      if params[:per_page]
        per_page = params[:per_page].to_i
        per_page = 5 if per_page < 5 # Even for small screens, show at least 5 terms per page
      else
        per_page = 20
      end

      @authorized_terms = AuthorizedTerm.includes(:controlled_vocabulary).where(
        'value LIKE ? OR value_uri LIKE ?', '%' + params[:q] + '%', '%' + params[:q] + '%'
      ).order(:value => :asc).page(page).per(per_page)
    end

    respond_to do |format|
      format.html {
        # Render normal html view
      }
      format.json {
        render json: {
          authorized_terms: @authorized_terms.map{|authorized_term| {value: authorized_term.value, value_uri: authorized_term.value_uri} },
          more_available: params[:uri_list].present? ? false : (@authorized_terms.next_page != nil)
        }
      }
    end
  end

  # GET /controlled_vocabularies/1
  # GET /controlled_vocabularies/1.json
  def show
  end

  # GET /controlled_vocabularies/new
  def new
    @controlled_vocabulary = ControlledVocabulary.new
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

  def authorized_terms

    # TODO: Use Solr for this kind of search instead.  values and value_uri fields are text because they might be long, so we can't index them in MySQL.  This will get slow with lots of terms.

    if params[:page]
      page = params[:page].to_i
    else
      page = 1
    end

    if params[:per_page]
      per_page = params[:per_page].to_i
      per_page = 5 if per_page < 5 # Even for small screens, show at least 5 terms per page
    else
      per_page = 20
    end

    if params[:q].blank?
      @authorized_terms = AuthorizedTerm.where(controlled_vocabulary: @controlled_vocabulary).order(:value => :asc).page(page).per(per_page)
    else
      @authorized_terms = AuthorizedTerm.where(controlled_vocabulary: @controlled_vocabulary).where(
        'value LIKE ? OR value_uri LIKE ?', '%' + params[:q] + '%', '%' + params[:q] + '%'
      ).order(:value => :asc).page(page).per(per_page)
    end

    respond_to do |format|
      format.html {
        # Render normal html view
      }
      format.json {
        render json: {
          authorized_terms: @authorized_terms.map{|authorized_term| {value: authorized_term.value, value_uri: authorized_term.value_uri} },
          more_available: (@authorized_terms.next_page != nil),
          current_user_can_add_terms: current_user.can_manage_controlled_vocabulary_terms?(@controlled_vocabulary)
        }
      }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_controlled_vocabulary
    @controlled_vocabulary = ControlledVocabulary.find(params[:id])
  end

  def set_controlled_vocabular_by_id_or_string_key
    if params[:id] =~ /[0-9]+/
      @controlled_vocabulary = ControlledVocabulary.find(params[:id])
    else
      @controlled_vocabulary = ControlledVocabulary.find_by(string_key: params[:id])
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def controlled_vocabulary_params
    params.require(:controlled_vocabulary).permit(:pid, :string_key, :display_label, :pid_generator_id, :only_managed_by_admins)
  end

  def set_contextual_nav_options

    case params[:action]
    when 'index'
      @contextual_nav_options['nav_title']['label'] =  'Controlled Vocabularies'.html_safe

      @contextual_nav_options['nav_items'].push(label: 'Add New Controlled Vocabulary', url: new_controlled_vocabulary_path) if current_user.is_admin?
    when 'search'
      @contextual_nav_options['nav_title']['label'] =  '&laquo; Back to Controlled Vocabularies'.html_safe
      @contextual_nav_options['nav_title']['url'] = controlled_vocabularies_path
    when 'edit', 'update'
      @contextual_nav_options['nav_items'].push(label: 'Delete This Controlled Vocabulary', url: controlled_vocabulary_path(@controlled_vocabulary.id), options: {method: :delete, data: { confirm: 'Are you sure you want to delete this Controlled Vocabulary?' } }) if current_user.is_admin?
    when 'authorized_terms'
      if current_user.can_manage_controlled_vocabulary_terms?(@controlled_vocabulary)
        @contextual_nav_options['nav_items'].push(label: 'New Authorized Term', url: new_authorized_term_path(controlled_vocabulary_id: @controlled_vocabulary.id))
      end
    end

  end

  def require_appropriate_permissions!

    case params[:action]
    when 'index', 'authorized_terms'
      # Do nothing
    else
      require_hyacinth_admin!
    end

  end

end
