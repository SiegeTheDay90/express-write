# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root 'application#splash'
  get '/csrf', to: "application#csrf"

  # Stats Page
  get '/stats', to: 'application#stats', as: 'stats'

  # Temp Letter
  get '/temp/:id', to: 'letters#temp', as: 'temp_letter'

  # Resumes
  get '/resume-tool', to: 'resumes#new'
  post '/resumes', to: 'resumes#create'

  # AJAX Polling
  get '/check/:id', to: 'requests#check', as: 'check'

  # Bug Report
  get  '/bug-report', to: 'bug_reports#new', as: 'bug_report'
  post '/bug-report', to: 'bug_reports#create'

  # Generators
  get '/bullets', to: 'resumes#suggest_bullets', as: 'suggest_bullets'
  post '/express', to: 'letters#express', as: 'express_letter'
  get '/url-check', to: 'application#valid_url?', as: 'valid_url'

  # Testing Routes
  get '/ads', to: 'application#ads'
  unless Rails.env.production?
    get '/err-test', to: 'application#err_test' # raises uncaught error "Test Error: Date.today"
    get '/test', to: 'application#test' # Test route generates letter using GPT-4 or other test model
    get '/stress-test', to: 'application#stress_test' # Makes multiple Async requests. Default backend maxes out at 3 concurrent processes.
  end

  # Catch-all
  get '*unmatched_route', to: redirect('/404.html'), via: :all
end
