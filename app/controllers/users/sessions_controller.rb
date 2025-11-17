class Users::SessionsController < Devise::SessionsController
  # GET /users/sign_in
  def new
    super
  end

  # DELETE /users/sign_out
  def destroy
    super
  end
end
