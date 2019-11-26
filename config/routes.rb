# frozen_string_literal: true

Rails.application.routes.draw do
  mount GraphiQL::Rails::Engine, at: '/graphiql', graphql_path: '/graphql' if Rails.env.development?

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
      end

      resources :vocabularies, param: :string_key, except: [:new, :edit] do
        resources :custom_fields, param: :field_key, except: [:new, :edit, :show, :index], module: 'vocabularies'
        resources :terms,         param: :uri,       except: [:new, :edit],                module: 'vocabularies', constraints: { uri: /.*/ }
      end

      resources :projects, param: :string_key, except: [:new, :edit] do
        resources :publish_targets, param: :string_key, except: [:new, :edit], module: 'projects'
        resources :field_sets,                          except: [:new, :edit], module: 'projects'
        resources :enabled_dynamic_fields,
                  only: [:show, :update], module: 'projects',
                  param: :digital_object_type, constraints: { digital_object_type: /(#{Hyacinth.config.digital_object_types.keys.join('|')})/ }
      end

      resources :dynamic_field_categories, except: [:new, :edit]
      resources :dynamic_field_groups,     except: [:new, :edit, :index]
      resources :dynamic_fields,           except: [:new, :edit, :index]

      resources :field_export_profiles,    except: [:new, :edit]
    end
  end
end
