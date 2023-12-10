Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "application#show"

  resource :session, only: [:new, :create, :destroy]
  resources :listings
  resources :letters, only: [:show, :edit, :update, :destroy]
  resources :profiles, only: [:new, :create, :edit, :update, :destroy]
  resources :users, only: [:new, :create, :show, :edit, :update] do
    resources :profiles, only: [:show]
    resources :listings, only: [:index]
  end

  # Stress Test
  get '/stresstest', to: 'application#stress_test'

  # Password Reset
  get '/reset', to: 'application#reset', as: 'reset_form'
  post '/reset', to: 'users#request_reset', as: 'request_reset'
  get '/confirmation/:token', to: 'users#confirm', as: 'user_confirmation'
  post '/reset/:token', to: 'users#reset_password', as: 'user_reset'

  # AJAX Polling
  get '/check/:id', to: 'requests#check', as: 'check'
  
  # User Details
  get '/details', to: 'users#details', as: 'details'

  # Bug Report
  get '/bugreport', to: 'application#bug', as: 'bug_report'

  # Mark Letters as Helpful
  patch '/letters/:id/helpful', to: 'letters#helpful', as: 'helpful_letter'

  # Login Routes
  get '/session/linkedin', to: 'sessions#linkedin'
  get '/session/demo', to: 'sessions#demo', as: 'demo_session'

  # Generators
  post '/letters/generate', to: 'letters#generate', as: 'generate_letter'
  post '/listings/generate', to: 'listings#generate', as: 'generate_listing'
  post '/users/generate', to: 'users#generate', as: 'generate_bio'
  post '/express', to: 'letters#express', as: 'express_letter'
  get '/express', to: 'application#express'
  
  # Other
  get '/test', to: 'application#test'
  get '*path', to: 'errors#not_found', via: :all
end
