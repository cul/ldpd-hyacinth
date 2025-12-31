class Api::V2::BaseController < ApplicationController
  # skip_before_action :verify_authenticity_token

  # Handle authorization errors
  rescue_from CanCan::AccessDenied do |exception|
    render json: { error: exception.message }, status: :forbidden
  end
end