Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "application#splash"

  get '/test', to: 'application#test'
  get '/bullets', to: 'resumes#suggest_bullets', as: 'suggest_bullets'

  resource :session, only: [:show, :new, :create, :destroy]
  resources :listings
  resources :resumes
  resources :letters, only: [:show, :edit, :update, :destroy]
  resources :profiles, only: [:new, :create, :edit, :update, :destroy]
  resources :users, only: [:new, :create, :show, :edit, :update] do
    resources :profiles, only: [:show]
    resources :listings, only: [:index]
  end

  # Temp Letter
  get '/temp/:id', to: 'letters#temp', as: 'temp_letter'

  
  # Stress Test
  get '/stresstest', to: 'application#stress_test'
  
  # Password Reset
  get '/reset', to: 'application#reset', as: 'reset_form'
  post '/reset', to: 'users#request_reset', as: 'request_reset'
  get '/confirmation/:token', to: 'users#confirm', as: 'user_confirmation'
  post '/reset/:token', to: 'users#reset_password', as: 'user_reset'
  
  # AJAX Polling
  get '/check/:id', to: 'requests#check', as: 'check'
  
  # Bug Report
  get '/bugreport', to: 'application#bug', as: 'bug_report'
  
  # Mark Letter as Helpful
  patch '/letters/:id/helpful', to: 'letters#helpful', as: 'helpful_letter'
  
  # Set Profile as Active
  get '/profiles/:id/activate', to: 'profiles#set_active', as: 'set_active'

  # Login Routes
  get '/session/linkedin', to: 'sessions#linkedin'
  get '/session/demo', to: 'sessions#demo', as: 'demo_session'
  
  # Generators
  post '/letters/generate', to: 'letters#generate', as: 'generate_letter'
  post '/listings/generate', to: 'listings#generate', as: 'generate_listing'
  post '/profiles/generate', to: 'profiles#generate', as: 'generate_profile'
  post '/express', to: 'letters#express', as: 'express_letter'
  post '/express-member', to: 'letters#express_member', as: 'express_member_letter'
  get '/express', to: 'application#express'
  get '/url-check', to: 'application#url_check', as: 'url_check'
  
  # Other
  get '/homepage', to: 'application#show'
  get '*unmatched_route', to: redirect('/404.html'), via: :all
end
