Rails.application.routes.draw do
  get '/users/do_cas_login', to: 'users#do_cas_login', as: :user_do_cas_login
  devise_for :users

  root to: redirect('ui/v1')
  get 'ui', to: redirect('ui/v1')
  get 'ui/v1', to: 'ui#v1'
  # wildcard *path route so that everything under ui/v1 gets routed to the single-page app
  get 'ui/v1/*path', to: 'ui#v1'

  namespace :api do
    namespace :v1 do
      resources :digital_objects, except: :index do
        collection do
          # allow GET or POST for search action requests
          # so we don't run into param length limits
          get 'search'
          post 'search'
        end
      end
      # resources :users do
      #   collection do
      #     get 'current'
      #   end
      # end
    end
  end
end
