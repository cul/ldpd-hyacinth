class AuthorizedTermsController < ApplicationController
  before_action :adjust_params_if_controlled_vocabulary_string_key_is_present, only: [:create]
  before_action :set_authorized_term, only: [:show, :edit, :update, :destroy]
  before_action :require_appropriate_permissions!
  before_action :set_contextual_nav_options

  # GET /authorized_terms/1
  # GET /authorized_terms/1.json
  def show
  end

  # GET /authorized_terms/new
  def new
    @authorized_term = AuthorizedTerm.new
    @authorized_term.controlled_vocabulary = ControlledVocabulary.find(params[:controlled_vocabulary_id])
  end

  # GET /authorized_terms/1/edit
  def edit
  end

  # POST /authorized_terms
  # POST /authorized_terms.json
  def create
    @authorized_term = AuthorizedTerm.new(authorized_term_params)

    respond_to do |format|
      if @authorized_term.save
        format.html { redirect_to @authorized_term, notice: 'Authorized term was successfully created.' }
        format.json {
          render json: {
            value: @authorized_term.value,
            value: @authorized_term.code,
            value_uri: @authorized_term.value_uri,
            authority: @authorized_term.authority,
            authority_uri: @authorized_term.authority_uri
          }
        }
      else
        format.html { render action: 'new' }
        format.json { render json: {
            errors: @authorized_term.errors
          }
        }
      end
    end
  end

  # PATCH/PUT /authorized_terms/1
  # PATCH/PUT /authorized_terms/1.json
  def update
    respond_to do |format|
      if @authorized_term.update(authorized_term_params)
        format.html { redirect_to @authorized_term, notice: 'Authorized term was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @authorized_term.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /authorized_terms/1
  # DELETE /authorized_terms/1.json
  def destroy
    @authorized_term.destroy
    respond_to do |format|
      format.html { redirect_to authorized_terms_url }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_authorized_term
    @authorized_term = AuthorizedTerm.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def authorized_term_params
    params.require(:authorized_term).permit(:pid, :value, :code, :value_uri, :authority, :authority_uri, :controlled_vocabulary_id)
  end

  def adjust_params_if_controlled_vocabulary_string_key_is_present
    # Also handle creation via controlled_vocabulary string_key
    if params[:authorized_term] && params[:authorized_term]['controlled_vocabulary_string_key'].present?
      controlled_vocabulary = ControlledVocabulary.find_by(string_key: params[:authorized_term]['controlled_vocabulary_string_key'])
      params[:authorized_term].delete('controlled_vocabulary_string_key')
      params[:authorized_term][:controlled_vocabulary_id] = controlled_vocabulary.id
    end
  end

  def require_appropriate_permissions!
    if params[:action] == 'new'
      controlled_vocabulary = ControlledVocabulary.find(params[:controlled_vocabulary_id])
    elsif params[:action] == 'create'
      controlled_vocabulary = ControlledVocabulary.find(params[:authorized_term]['controlled_vocabulary_id'])
    else
      controlled_vocabulary = @authorized_term.controlled_vocabulary
    end

    case params[:action]
    when 'new', 'create', 'edit', 'update', 'delete'
      require_controlled_vocabulary_permission!(controlled_vocabulary)
    end
  end

  def set_contextual_nav_options

    if params[:action] == 'new'
      controlled_vocabulary = ControlledVocabulary.find(params[:controlled_vocabulary_id])
    elsif params[:action] == 'create'
      controlled_vocabulary = ControlledVocabulary.find(params[:authorized_term]['controlled_vocabulary_id'])
    else
      controlled_vocabulary = @authorized_term.controlled_vocabulary
    end

    @contextual_nav_options['nav_title']['label'] =  ('&laquo; Back to Controlled Vocabulary: ' + controlled_vocabulary.display_label).html_safe
    @contextual_nav_options['nav_title']['url'] = authorized_terms_controlled_vocabulary_path(controlled_vocabulary)

    case params[:action]
    when 'show'
      @contextual_nav_options['nav_items'].push(label: 'Edit', url: edit_authorized_term_path(@authorized_term.id)) if current_user.can_manage_controlled_vocabulary_terms?(controlled_vocabulary)
    when 'edit', 'update'
      @contextual_nav_options['nav_title']['label'] =  ('&laquo; Cancel Edit').html_safe
      @contextual_nav_options['nav_title']['url'] = authorized_term_path(@authorized_term.id)

      @contextual_nav_options['nav_items'].push(label: 'Delete This Authorized Term', url: authorized_term_path(@authorized_term.id), options: {method: :delete, data: { confirm: 'Are you sure you want to delete this Authorized Term?' } }) if current_user.can_manage_controlled_vocabulary_terms?(controlled_vocabulary)
    end

  end
end
