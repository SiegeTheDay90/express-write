Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "application#show"

  resource :session, only: [:new, :create, :destroy]
  resources :listings, only: [:show, :new, :create, :edit, :update, :destroy]
  resources :letters, only: [:show, :edit, :update, :destroy]
  resources :users, only: [:new, :create, :show, :edit, :update] do
    resources :listings, only: [:index]
  end

  get '/check/:id', to: 'requests#check', as: 'check'
  get '/details', to: 'users#details', as: 'details'
  get '/bugreport', to: 'application#bug', as: 'bug_report'
  patch '/letters/:id/helpful', to: 'letters#helpful', as: 'helpful_letter'
  get '/session/linkedin', to: 'sessions#linkedin'
  get '/session/demo', to: 'sessions#demo', as: 'demo_session'
  post '/letters/generate', to: 'letters#generate', as: 'generate_letter'
  post '/listings/generate', to: 'listings#generate', as: 'generate_listing'
  post '/users/generate', to: 'users#generate', as: 'generate_bio'
  post '/express', to: 'letters#express', as: 'express_letter'
  get '/express', to: 'application#express'
  get '/test', to: 'application#test'
  get '*path', to: 'errors#not_found', via: :all
end
