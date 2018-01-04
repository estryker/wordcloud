Rails.application.routes.draw do
 
  root 'welcome#index'

  resources :surveys


  get 'surveys/:id/input', :to => 'surveys#input'
  get 'search', :to => 'surveys#search'

  post 'surveys/:id/input', :to => 'surveys#add_input'
  post 'search', :to => 'surveys#do_search'

  get 'welcome/index'

  #devise_for :users, controllers: {
  #      sessions: 'users/sessions'
  #    }

  devise_for  :users, :controllers =>  { registrations: 'registrations', omniauth_callbacks: "omniauth_callbacks" }
  resources :users
  get   '/login', :to => 'sessions#new', :as => :login
  
  # from: http://sourcey.com/rails-4-omniauth-using-devise-with-twitter-facebook-and-linkedin/
  match '/users/:id/finish_signup' => 'users#finish_signup', via: [:get, :patch], :as => :finish_signup

  # TODO: these were changed from 'match', make sure they work with get
  match '/auth/:provider/callback', :to => 'sessions#create', via: [:get,:post]
  match '/auth/failure', :to => 'sessions#failure', via: [:get,:post]

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
