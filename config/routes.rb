Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "application#splash"
  
  # Temp Letter
  get '/temp/:id', to: 'letters#temp', as: 'temp_letter'
  
  # Resumes 
  # resources :resumes
  
  # AJAX Polling
  get '/check/:id', to: 'requests#check', as: 'check'
  
  # Bug Report
  get  '/bug-report', to: 'bug_reports#new', as: 'bug_report'
  post '/bug-report', to: 'bug_reports#create'
  
  # Generators
  get '/bullets', to: 'resumes#suggest_bullets', as: 'suggest_bullets'
  post '/express', to: 'letters#express', as: 'express_letter'
  get '/url-check', to: 'application#url_check', as: 'url_check'

  # Testing Routes
    # Stress Test
    if !Rails.env.production? do
      get '/stresstest', to: 'application#stress_test' 
    end

  # Catch-all
  get '*unmatched_route', to: redirect('/404.html'), via: :all

end
