SC::Application.routes.draw do
  get "connection_types/index"

  get "testing_environments/index"

  get "testing_environments/new"

  get "testing_environments/show"

  get "testing_environments/edit"

  get "devices/index"

  resources :test_servers
  resources :test_cases, :only => [:show, :index, :update]
  resources :test_suites
  root :to => "splash#index"
  match ':controller(/:action(/:id(.:format)))'
end
