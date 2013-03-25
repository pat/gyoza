require 'sidekiq/web'

Gyoza::Application.routes.draw do
  root to: 'home#index'

  scope constraints: {path: /.*/, format: //} do
    get '/edit/:user/:repo/*path' => 'sites#show',   as: :site_show
    put '/edit/:user/:repo/*path' => 'sites#update', as: :site_update
  end

  get '/auth/:provider/callback', to: 'sessions#create'
  get '/sign_out',                to: 'sessions#destroy'

  mount Sidekiq::Web => '/sidekiq'
end
