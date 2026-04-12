# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root 'application#splash'
  get '/csrf', to: "application#csrf"

  # Stats Page
  get '/stats', to: 'application#stats', as: 'stats'

  # Jobs Page
  get '/sites', to: 'application#sites', as: 'sites'

  # Privacy Policy
  get '/privacy', to: 'application#privacy', as: 'privacy'

  # Temp Letter
  # get '/temp/:secure_id', to: 'letters#temp', as: 'temp_letter'
  delete '/letters/:secure_id/:tone', to: 'letters#destroy'
  patch '/letters/:secure_id/:tone', to: 'letters#update'
  post '/express', to: 'letters#express', as: 'express_letter'
  # get '/letters', to: 'letters#index', as: 'letters'
  get '/letters/:secure_id', to: 'letters#show', as: 'letter'
  
  
  # AJAX Polling
  get '/url-check', to: 'application#valid_url?', as: 'valid_url'
  get '/check/:id', to: 'requests#check', as: 'check'

  # Bug Report
  get  '/bug-report', to: 'bug_reports#new', as: 'bug_report'
  post '/bug-report', to: 'bug_reports#create'
  get  '/bug-reports', to: 'bug_reports#index', as: 'bug_reports'

  # Testing Routes
  unless Rails.env.production?
    get '/ads', to: 'application#ads'
    get '/err-test', to: 'application#err_test' # raises uncaught error "Test Error: Date.today"
    get '/test', to: 'application#test' # Test route generates letter using GPT-4 or other test model
    get '/stress-test', to: 'application#stress_test' # Makes multiple Async requests. Default backend maxes out at 3 concurrent processes.
  end

  # Catch-all
  get '*unmatched_route', to: redirect('/404.html'), via: :all
end
