require 'sidekiq/web'

Gyoza::Application.routes.draw do
  scope constraints: {path: /.*/, format: //} do
    get '/edit/:user/:repo/*path' => 'sites#show'
    put '/edit/:user/:repo/*path' => 'sites#update'
  end

  get '/auth/:provider/callback', to: 'sessions#create'
  get '/sign_out',                to: 'sessions#destroy'

  mount Sidekiq::Web => '/sidekiq'
end
