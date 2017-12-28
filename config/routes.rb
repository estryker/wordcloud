Rails.application.routes.draw do
  devise_for :users, controllers: {
        sessions: 'users/sessions'
      }

  root 'welcome#index'

  get 'survey/index'

  get 'survey/results'

  get 'survey/input'

  get 'survey/admin'

  get 'survey/new'

  get 'welcome/index'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
