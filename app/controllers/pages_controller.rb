class PagesController < ApplicationController
  # GET /home
  def home
    redirect_to digital_objects_path if user_signed_in?
  end

  # GET /login_check
  def login_check
    # user = User.where(email: 'hyacinth-admin@library.columbia.edu').first
    # sign_in user, :bypass => true
    # raise user.errors.inspect
    if user_signed_in?
      render plain: 'true'
    else
      render plain: 'false'
    end
  end

  # GET /get_csrf_token
  def csrf_token
    render inline: form_authenticity_token
  end

  def system_information
    require_hyacinth_admin!
  end
end
