class UsersController < ApplicationController
  include Hyacinth::Users::CasAuthenticationBehavior
end
