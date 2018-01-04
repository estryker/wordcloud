Rails.application.routes.draw do
  devise_for :users, controllers: {
        sessions: 'users/sessions'
      }

  root 'welcome#index'

  resources :surveys


  get 'surveys/:id/input', :to => 'surveys#input'
  get 'search', :to => 'surveys#search'

  post 'surveys/:id/input', :to => 'surveys#add_input'
  post 'search', :to => 'surveys#do_search'

  get 'welcome/index'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
