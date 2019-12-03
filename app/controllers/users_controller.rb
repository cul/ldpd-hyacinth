# frozen_string_literal: true

class UsersController < ApplicationController
  include Hyacinth::Users::CasAuthenticationBehavior
end
