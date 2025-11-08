class UsersController < ApplicationController
  API_TOKEN_LENGTH = 32

  before_action :require_hyacinth_admin!, except: [:current_user_data]
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :set_contextual_nav_options

  # GET /users
  # GET /users.json
  def index
    @users = User.all.order(uid: :asc)
  end

  # GET /users/email_list
  def email_list
    email_addresses = User.all.map(&:email)
    respond_to do |format|
      format.json { render json: email_addresses }
      format.html { render plain: email_addresses.join(',') }
    end
  end

  def current_user_data
    respond_to do |format|
      format.json do
        render json: current_user
      end
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render action: 'show', status: :created, location: @user }
      else
        format.html { render action: 'new' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      processed_user_params = user_params
      generate_new_api_key = processed_user_params.delete(:generate_new_api_key)

      if @user.update(
        processed_user_params.merge(generate_new_api_key ? { api_key: Devise.friendly_token(API_TOKEN_LENGTH) } : {})
      )
        format.html do
          redirect_to(
            @user,
            notice: 'User was successfully updated.',
            persistent_notice: @user.api_key.present? ? "Your new API key is:\n#{@user.api_key}.\nThis information will only be shown once." : nil
          )
        end
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    # Before deleting a user, verify that at least one admin user still exists
    if User.where(is_admin: true).where.not(id: @user.id).count == 0
      flash[:alert] = 'You cannot delete the only remaining admin user.'
    else
      @user.destroy
    end

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(
        :uid, :email, :first_name, :last_name,
        :is_admin, :can_manage_all_controlled_vocabularies, :is_active,
        :generate_new_api_key, :account_type
      )
    end

    def set_contextual_nav_options
      @contextual_nav_options['nav_title']['label'] = 'Users'
      @contextual_nav_options['nav_title']['url'] = users_path

      case params[:action]
      when 'index'
        @contextual_nav_options['nav_items'].push(label: 'Add New User', url: new_user_path)
      when 'show'
        @contextual_nav_options['nav_items'].push(label: '<span class="glyphicon glyphicon-edit"></span> Edit This User'.html_safe, url: edit_user_path(@user.id))
      when 'edit', 'update'
        @contextual_nav_options['nav_items'].push(label: 'Delete This User', url: user_path(@user.id), options: { method: :delete, data: { confirm: 'Are you sure you want to delete this User?' } })

        @contextual_nav_options['nav_title']['label'] =  '&laquo; Back to Users'.html_safe
        @contextual_nav_options['nav_title']['url'] = users_path
      end
    end
end
