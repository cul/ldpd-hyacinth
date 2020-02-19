# frozen_string_literal: true

Rails.application.routes.draw do
  # Constraint for restricting certain routes to only admins, or to the development environment
  dev_or_admin_constraints = lambda do |request|
    return true if Rails.env.development?
    current_user = request.env['warden'].user
    current_user&.is_admin?
  end

  # For now, we can only use GraphiQL in the development environmnent (due to a js compilation issue in prod).
  if Rails.env.development?
    constraints dev_or_admin_constraints do
      mount GraphiQL::Rails::Engine, at: '/graphiql', graphql_path: '/graphql'
    end
  end

  post "/graphql", to: "graphql#execute"

  get '/users/do_cas_login', to: 'users#do_cas_login', as: :user_do_cas_login
  devise_for :users

  root to: redirect('ui/v1')
  get 'ui', to: redirect('ui/v1')
  get 'ui/v1', to: 'ui#v1'
  # wildcard *path route so that everything under ui/v1 gets routed to the single-page app
  get 'ui/v1/*path', to: 'ui#v1'

  namespace :api do
    namespace :v1, defaults: { format: :json } do
      resources :digital_objects, except: :index do
        collection do
          # allow GET or POST for search action requests so we don't run into param length limits
          get 'search'
          post 'search'
          post ':id/publish' => 'digital_objects#publish', as: :publish
          post ':id/preserve' => 'digital_objects#preserve', as: :preserve
        end
        member do
          resource :rights, controller: 'digital_objects/rights', only: [:show, :edit, :update]
          resource :uploads, controller: 'digital_objects/uploads', only: [:create]
          get 'resources/:resource_name/download' => 'digital_objects/resources#download', as: :download_resource
        end
      end

      resources :projects, param: :string_key, only: [:show] do
        resources :publish_targets, param: :string_key, except: [:new, :edit], module: 'projects'
        resources :field_sets,                          except: [:new, :edit], module: 'projects'
        resources :enabled_dynamic_fields,
                  only: [:show, :update], module: 'projects',
                  param: :digital_object_type, constraints: { digital_object_type: /(#{Hyacinth::Config.digital_object_types.keys.join('|')})/ }
      end

      resources :dynamic_field_categories, only: [:index]
    end
  end
end
